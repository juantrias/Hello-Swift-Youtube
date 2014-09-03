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
public class YoutubeSearchDataProvider: NSObject, AWPagedArrayDelegate {
    
    public var dataObjects: AWPagedArray {
        return self.pagedArray
    }
    
    private var pagedArray: AWPagedArray
    private var searchString: String
    private var pageTokens: [UInt: String] //pageNumber -> pageToken
    private var pagesWithOngoingRequests: [UInt: Bool] //pageNumber -> True
    private var delegate: YoutubeSearchDataProviderDelegate
    
    // dataCount: total results from YouTube API
    init(searchString: String, dataCount: UInt, initialObjects: [AnyObject], nextPageToken: String, delegate: YoutubeSearchDataProviderDelegate) {
        self.searchString = searchString
        self.pagedArray = AWPagedArray(count: dataCount, objectsPerPage: YoutubeManager.sharedInstance.RESULTS_PER_PAGE)
        self.pagedArray.setObjects(initialObjects, forPage: 1) // Pages start at 1
        self.pageTokens = [2: nextPageToken]
        self.pagesWithOngoingRequests = [UInt: Bool]()
        self.delegate = delegate
        super.init()
        self.pagedArray.delegate = self
    }
    
    // MARK: - Private methods
    
    private func loadDataForPageIfNeeded(page: UInt) {
        if (pagedArray.pages[page] == nil && pagesWithOngoingRequests[page] == nil) {
            loadDataForPage(page)
            // TODO si la pagina no esta visible cancelar la request
        }
    }
    
    private func loadDataForPage(page: UInt) {
        self.pagesWithOngoingRequests[page] = true
        let indexes = pagedArray.indexSetForPage(page)
        self.delegate.dataProvider?(self, willLoadDataAtIndexes:indexes)
        
        let pageToken = pageTokens[page]
        YoutubeManager.sharedInstance.search(searchString, pageToken: pageToken
            , onSuccess: { (searchListJSONModel: YUSearchListJSONModel) -> Void in
                self.pagesWithOngoingRequests.removeValueForKey(page)
                self.pagedArray.setObjects(searchListJSONModel.items, forPage: page)
                if (page > 1) {
                    self.pageTokens[page-1] = searchListJSONModel.prevPageToken
                }
                if (page < self.pagedArray.numberOfPages) {
                    self.pageTokens[page+1] = searchListJSONModel.nextPageToken
                }
                self.delegate.dataProvider(self, didLoadDataAtIndexes: indexes)
                println("YoutubeManager search onSuccess for page \(page)")
            }
            , onError: { (error: NSError) -> Void in
                // We need to assign the value returned by pagesWithOngoingRequests to bypass the compiler error
                let aux = self.pagesWithOngoingRequests.removeValueForKey(page)
            }
        )
        
    }
    
    // MARK: - Paged array delegate
    public func pagedArray(pagedArray: AWPagedArray!, willAccessIndex index: UInt, returnObject: AutoreleasingUnsafeMutablePointer<AnyObject?>) {
        
        let page = pagedArray.pageForIndex(index)
        if (returnObject.memory!.isKindOfClass(NSNull)) {
            loadDataForPageIfNeeded(page)
            
        } else { // preload Next Page If Needed
            let preloadPage = pagedArray.pageForIndex(index + YoutubeManager.sharedInstance.RESULTS_PER_PAGE)
            if (preloadPage > page && preloadPage <= pagedArray.numberOfPages) {
                loadDataForPageIfNeeded(preloadPage)
            }
        }
    }
    
}