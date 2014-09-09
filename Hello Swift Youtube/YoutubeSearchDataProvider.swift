//
//  YoutubeSearchDataProvider.swift
//  Hello Swift Youtube
//
//  Created by Juan on 02/09/14.
//  Copyright (c) 2014 IGZ. All rights reserved.
//

import Foundation

// Necesitamos marcar tanto el protocol como la class como @objc para poder declarar métodos optional

@objc
protocol YoutubeSearchDataProviderDelegate {
    optional func dataProvider(dataProvider: YoutubeSearchDataProvider, willLoadDataAtIndexes indexes:NSIndexSet)
    func dataProvider(dataProvider: YoutubeSearchDataProvider, didLoadDataAtIndexes indexes:NSIndexSet)
}

@objc
public class YoutubeSearchDataProvider: NSObject {
    
    private var pagedScrollHelper: PagedScrollHelper?
    private var totalVideoCount: Int {
        get {
            let t = NSUserDefaults.standardUserDefaults().integerForKey(SP_KEY_LAST_SEARCH_RESULT_COUNT)
            println("get totalVideoCount \(t)")
            return t
        }
        set {
            println("set totalVideoCount \(newValue)")
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: SP_KEY_LAST_SEARCH_RESULT_COUNT)
        }
    }
    private var videos: RLMArray?
    private var searchString: String? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey(SP_KEY_LAST_CACHED_SEARCH_STRING) as? String
        }
        set {
            if (newValue != nil) {
                NSUserDefaults.standardUserDefaults().setObject(newValue!, forKey: SP_KEY_LAST_CACHED_SEARCH_STRING)
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey(SP_KEY_LAST_CACHED_SEARCH_STRING)
            }
        }
    }
    private var pageTokens: [String: String] //pageNumber -> pageToken
    private var cachedPages: [String: Bool] //pageNumber -> True
    private var pagesWithOngoingRequests: [UInt: Bool] //pageNumber -> True
    private var notificationToken: RLMNotificationToken?
    private var delegate: YoutubeSearchDataProviderDelegate
    
    init(delegate: YoutubeSearchDataProviderDelegate) {
        self.pagesWithOngoingRequests = [UInt: Bool]()
        
        let spPageTokens = NSUserDefaults.standardUserDefaults().objectForKey(SP_KEY_LAST_SEARCH_PAGE_TOKENS) as? [String: String]
        println("get pageTokens: \(spPageTokens)")
        if (spPageTokens != nil) {
            self.pageTokens = spPageTokens!
        } else {
            self.pageTokens = [String: String]()
        }
        
        let spCachedPages = NSUserDefaults.standardUserDefaults().objectForKey(SP_KEY_LAST_SEARCH_CACHED_PAGES) as? [String: Bool]
        println("get cachedPages: \(spCachedPages)")
        if (spCachedPages != nil) {
            self.cachedPages = spCachedPages!
        } else {
            self.cachedPages = [String: Bool]()
        }
        
        self.delegate = delegate
        
        // Hay alguna forma de actualizar self.videos sin volver a cargar todos los videos desde Realm?
        self.videos = VideoDto.allObjects()
        
        super.init()
    }
    
    public func search(searchString: String, onSuccess: (videos: [VideoDto]) -> Void, onError: (error: NSError) -> Void ) {
        
        let lastCachedSearchString = NSUserDefaults.standardUserDefaults().stringForKey(SP_KEY_LAST_CACHED_SEARCH_STRING)
        if (lastCachedSearchString != searchString) {
            
            let page: UInt = 1
            
            // Make API call:
            YoutubeManager.sharedInstance.search(searchString, pageToken: nil
                , onSuccess: { (searchListJSONModel: YUSearchListJSONModel) -> Void in
                    
                    self.resetSearchResults()
                    self.searchString = searchString
                    
                    // Instantiate pagedScrollHelper with totalCount
                    self.pagedScrollHelper = PagedScrollHelper(count: searchListJSONModel.pageInfo.totalResults, objectsPerPage: YoutubeManager.sharedInstance.RESULTS_PER_PAGE)
                    
                    self.totalVideoCount = searchListJSONModel.pageInfo.totalResults
                    let videos = self.saveSearchResults(searchListJSONModel, page: page)
                    
                    self.cachedPages[String(page)] = true
                    if (page > 1) {
                        self.pageTokens[String(page-1)] = searchListJSONModel.prevPageToken
                    }
                    if (page < self.pagedScrollHelper!.numberOfPages()) {
                        self.pageTokens[String(page+1)] = searchListJSONModel.nextPageToken
                    }
                    
                    NSUserDefaults.standardUserDefaults().setDictionary(self.cachedPages, forKey:SP_KEY_LAST_SEARCH_CACHED_PAGES)
                    NSUserDefaults.standardUserDefaults().setDictionary(self.pageTokens, forKey:SP_KEY_LAST_SEARCH_PAGE_TOKENS)
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    // Reload data at VC
                    onSuccess(videos: videos)
                    
                }, onError: { (error: NSError) -> Void in
                    onError(error: error)
            })
            
        
        } else {
            // Fetch data from Realm and store in PagedArray
            self.videos = VideoDto.allObjects()
            self.pagedScrollHelper = PagedScrollHelper(count: UInt(self.totalVideoCount), objectsPerPage: YoutubeManager.sharedInstance.RESULTS_PER_PAGE)
            // self.delegate.dataProvider(self, didLoadDataAtIndexes: indexes)
        }
        
        
        //
    }
    
    // MARK: - Private methods
    
    private func resetSearchResults() {
        
        // Delete previous results from Realm
        deleteAllVideos()
        
        self.pageTokens = [String: String]()
        self.cachedPages = [String: Bool]()
        self.pagesWithOngoingRequests = [UInt: Bool]()
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey(SP_KEY_LAST_SEARCH_PAGE_TOKENS)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(SP_KEY_LAST_SEARCH_CACHED_PAGES)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // MARK: - Private methods: Realm
    
    private func deleteAllVideos() {
        RealmHelper.sharedHelper.writeAsync({ (realm: RLMRealm) -> Void in
            let videos = VideoDto.allObjects()
            realm.beginWriteTransaction()
            realm.deleteObjects(videos)
            realm.commitWriteTransaction()
        })
    }
    
    /**
    Save JSON Objects to Realm
    */
    private func saveSearchResults(searchListJSONModel: YUSearchListJSONModel, page: UInt) -> [VideoDto] {
        
        var newVideos = [VideoDto]()
        for item in searchListJSONModel.items {
            let videoDto = VideoDto(itemJsonModel: item as YUItemJSONModel)
            newVideos.append(videoDto)
        }
        
        RealmHelper.sharedHelper.writeAsync { (realm: RLMRealm) in
            // This block is executed in other thread, so we obtain a RLMRealm instance for this thread
            // From Realm docs: "Do not share RLMRealm objects across threads"
            println("Default realm path \(realm.path)")
            // Add all objects to the Realm inside a single transaction
            // From Realm docs: "unless you need to make simultaneous writes from many threads at once, you should favor larger write transactions that do more work over many fine-grained write transactions"
            realm.beginWriteTransaction()
            realm.addObjectsFromArray(newVideos)
            realm.commitWriteTransaction()
            
            dispatch_async(dispatch_get_main_queue(), {
                self.videos = VideoDto.allObjects()
                let indexes = self.pagedScrollHelper!.indexSetForPage(page)
                self.delegate.dataProvider(self, didLoadDataAtIndexes: indexes)
            })
        }
     
        // Note that objects are returned before being added to the Realm. This way the UI can print the results
        return newVideos
    }
    
    // MARK: - Private methods: Pagination
    
    private func loadDataForPageIfNeeded(page: UInt) {
        if (cachedPages[String(page)] == nil && pagesWithOngoingRequests[page] == nil) {
            loadDataForPage(page)
            // TODO: si la pagina no esta visible cancelar la request
        }
    }
    
    private func loadDataForPage(page: UInt) {
        if (pagedScrollHelper == nil || searchString == nil) {
            return
        }

        self.pagesWithOngoingRequests[page] = true
        let indexes = pagedScrollHelper!.indexSetForPage(page)
        self.delegate.dataProvider?(self, willLoadDataAtIndexes:indexes)
        
        let pageToken = pageTokens[String(page)]
        YoutubeManager.sharedInstance.search(searchString!, pageToken: pageToken
            , onSuccess: { (searchListJSONModel: YUSearchListJSONModel) -> Void in
                
                let videos = self.saveSearchResults(searchListJSONModel, page: page)
                
                self.pagesWithOngoingRequests.removeValueForKey(page)
                self.cachedPages[String(page)] = true
                if (page > 1) {
                    self.pageTokens[String(page-1)] = searchListJSONModel.prevPageToken
                }
                if (page < self.pagedScrollHelper!.numberOfPages()) {
                    self.pageTokens[String(page+1)] = searchListJSONModel.nextPageToken
                }
                
                NSUserDefaults.standardUserDefaults().setDictionary(self.cachedPages, forKey:SP_KEY_LAST_SEARCH_CACHED_PAGES)
                NSUserDefaults.standardUserDefaults().setDictionary(self.pageTokens, forKey:SP_KEY_LAST_SEARCH_PAGE_TOKENS)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                self.delegate.dataProvider(self, didLoadDataAtIndexes: indexes)
                println("YoutubeManager search onSuccess for page \(page) pageToken \(pageToken)")
            }
            
            , onError: { (error: NSError) -> Void in
                self.pagesWithOngoingRequests.removeValueForKey(page)
                let alertView = ErrorUIHelper.alertViewForError(error)
                alertView.show()
            }
        )
        
    }
    
    // MARK: - Data methods
    
    public func itemCount() -> Int {
        return totalVideoCount
    }
    
    public func itemAtIndex(index: UInt) -> VideoDto? {
        
        if (pagedScrollHelper == nil) {
            return nil
        }
        
        let page = pagedScrollHelper!.pageForIndex(index)
        
        if (videos != nil && index < videos!.count) {
            let preloadPage = pagedScrollHelper!.pageForIndex(index + YoutubeManager.sharedInstance.RESULTS_PER_PAGE)
            if (preloadPage > page && preloadPage <= pagedScrollHelper!.numberOfPages()) {
                loadDataForPageIfNeeded(preloadPage)
            }
            return videos![index] as? VideoDto
        
        } else {
            loadDataForPageIfNeeded(page)
            return nil
        }
    }
    
}