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
protocol YoutubeManagerDelegate {
    optional func dataProvider(dataProvider: YoutubeManager, willLoadDataAtIndexes indexes:NSIndexSet)
    func dataProvider(dataProvider: YoutubeManager, didLoadDataAtIndexes indexes:NSIndexSet)
}

@objc
public class YoutubeManager: NSObject {
    
    public let RESULTS_PER_PAGE: UInt = 20
    
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
    private var lastSearchString: String? {
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
    private var delegate: YoutubeManagerDelegate
    
    init(delegate: YoutubeManagerDelegate) {
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
    
    // MARK: - Public methods
    
    public func search(searchString: String, onSuccess: (videos: [VideoDto]) -> Void, onError: (error: NSError) -> Void ) {
        
        let lastCachedSearchString = NSUserDefaults.standardUserDefaults().stringForKey(SP_KEY_LAST_CACHED_SEARCH_STRING)
        
        if (lastCachedSearchString != searchString) {
            searchOnApi(searchString, page:1, pageToken: nil, isFirstPage: true, onSuccess:onSuccess, onError: onError)
            
        } else {
            // Fetch data from Realm and store in PagedArray
            self.videos = VideoDto.allObjects()
            self.pagedScrollHelper = PagedScrollHelper(count: UInt(self.totalVideoCount), objectsPerPage: RESULTS_PER_PAGE)
            // self.delegate.dataProvider(self, didLoadDataAtIndexes: indexes)
        }
    }
    
    public func searchResultsCount() -> Int {
        return totalVideoCount
    }
    
    public func searchResultsVideoAtIndex(index: UInt) -> VideoDto? {
        
        if (pagedScrollHelper == nil) {
            return nil
        }
        
        let page = pagedScrollHelper!.pageForIndex(index)
        
        if (videos != nil && index < videos!.count) {
            let preloadPage = pagedScrollHelper!.pageForIndex(index + RESULTS_PER_PAGE)
            if (preloadPage > page && preloadPage <= pagedScrollHelper!.numberOfPages()) {
                loadDataForPageIfNeeded(preloadPage)
            }
            return videos![index] as? VideoDto
            
        } else {
            loadDataForPageIfNeeded(page)
            return nil
        }
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
    
    // MARK: - Private methods: REST API
    
    private func searchOnApi(searchString: String, page: UInt, pageToken: String?, isFirstPage: Bool, onSuccess: (videos: [VideoDto]) -> Void, onError: (error: NSError) -> Void) {
        
        YoutubeApiClient.sharedClient.search(searchString, pageToken: pageToken, resultsPerPage: RESULTS_PER_PAGE
            , onSuccess: { (newVideos: [VideoDto], totalVideos: UInt, prevPageToken: String?, nextPageToken: String?) -> Void in
                if (isFirstPage) {
                    self.resetSearchResults()
                    self.lastSearchString = searchString
                    // Instantiate pagedScrollHelper with totalCount
                    self.pagedScrollHelper = PagedScrollHelper(count: totalVideos, objectsPerPage: self.RESULTS_PER_PAGE)
                    self.totalVideoCount = Int(totalVideos)
                }
                
                self.saveSearchResults(newVideos, page: page)
                
                self.pagesWithOngoingRequests.removeValueForKey(page)
                self.cachedPages[String(page)] = true

                if (page > 1) {
                    self.pageTokens[String(page-1)] = prevPageToken!
                }
                if (page < self.pagedScrollHelper!.numberOfPages()) {
                    self.pageTokens[String(page+1)] = nextPageToken!
                }
                
                NSUserDefaults.standardUserDefaults().setDictionary(self.pageTokens, forKey:SP_KEY_LAST_SEARCH_PAGE_TOKENS)
                NSUserDefaults.standardUserDefaults().setDictionary(self.cachedPages, forKey:SP_KEY_LAST_SEARCH_CACHED_PAGES)
                NSUserDefaults.standardUserDefaults().synchronize()

                // Se hace desde saveSearchResults
                //self.delegate.dataProvider(self, didLoadDataAtIndexes: indexes)
                println("YoutubeManager search onSuccess for page \(page) pageToken \(pageToken)")
                onSuccess(videos: newVideos)
                
            }, onError: {  (error: NSError) -> Void in
                onError(error: error)
            })
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
    private func saveSearchResults(videos: [VideoDto], page: UInt) {
        
        RealmHelper.sharedHelper.writeAsync { (realm: RLMRealm) in
            // This block is executed in other thread, so we obtain a RLMRealm instance for this thread
            // From Realm docs: "Do not share RLMRealm objects across threads"
            println("Default realm path \(realm.path)")
            // Add all objects to the Realm inside a single transaction
            // From Realm docs: "unless you need to make simultaneous writes from many threads at once, you should favor larger write transactions that do more work over many fine-grained write transactions"
            realm.beginWriteTransaction()
            realm.addObjectsFromArray(videos)
            realm.commitWriteTransaction()
            
            dispatch_async(dispatch_get_main_queue(), {
                self.videos = VideoDto.allObjects()
                let indexes = self.pagedScrollHelper!.indexSetForPage(page)
                self.delegate.dataProvider(self, didLoadDataAtIndexes: indexes)
            })
        }
    }
    
    // MARK: - Private methods: Pagination
    
    private func loadDataForPageIfNeeded(page: UInt) {
        if (cachedPages[String(page)] == nil && pagesWithOngoingRequests[page] == nil) {
            loadDataForPage(page)
            // TODO: si la pagina no esta visible cancelar la request
        }
    }
    
    private func loadDataForPage(page: UInt) {
        if (pagedScrollHelper == nil || lastSearchString == nil) {
            return
        }

        self.pagesWithOngoingRequests[page] = true
        let indexes = pagedScrollHelper!.indexSetForPage(page)
        self.delegate.dataProvider?(self, willLoadDataAtIndexes:indexes)
        
        let pageToken = pageTokens[String(page)]
        
        searchOnApi(lastSearchString!, page: page, pageToken: pageToken, isFirstPage: false
            , onSuccess: { (videos: [VideoDto]) -> Void in
                //Do nothing
            }, onError: { (error: NSError) -> Void in
                //Do nothing
        })
    }
    
}