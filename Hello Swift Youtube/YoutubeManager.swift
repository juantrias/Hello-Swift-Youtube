//
//  YoutubeManager.swift
//  Hello Swift
//
//  Created by Juan on 11/07/14.
//  Copyright (c) 2014 IGZ. All rights reserved.
//

import Foundation

let sharedYoutubeManager = YoutubeManager()

class YoutubeManager {
    class var sharedInstance:YoutubeManager {
        return sharedYoutubeManager
    }
    
    let YOUTUBE_API_URL = "https://www.googleapis.com/youtube/v3/"
    let YOUTUBE_API_SEARCH = "search"
    let YOUTUBE_API_KEY = "AIzaSyAFUUlXucib_q6uw7tw_3G-s9FzHy39c8U"
    
    var sessionManager: AFHTTPSessionManager
    var requestManager: AFHTTPRequestOperationManager
    
    init() {
        sessionManager = AFHTTPSessionManager(baseURL: NSURL(string: YOUTUBE_API_URL))
        requestManager = AFHTTPRequestOperationManager(baseURL: NSURL(string: YOUTUBE_API_URL))
    }
    
    func search(query: String, onSuccess: (YUSearchListJSONModel) -> Void, onError: (NSError) -> Void) {
        // TODO bridgeToObjectiveC() unneccessary in XCode 6 Beta 3?
        var params = ["part": "id,snippet", "q": query, "type": "video", "key": YOUTUBE_API_KEY].bridgeToObjectiveC()
        
        requestManager.GET(YOUTUBE_API_SEARCH, parameters: params, clazz:YUSearchListJSONModel.classForCoder()
        , success: {(operation: AFHTTPRequestOperation!, response: AnyObject!) in
            let searchListJSONModel = response as YUSearchListJSONModel
            //println("searchListJSONModel: \(searchListJSONModel)")
            onSuccess(searchListJSONModel)
        }
        , failure: {(operation: AFHTTPRequestOperation!, error: NSError!) in
            println("Error received \(error)")
            println("Operation \(operation.request)")
            onError(error)
        })
    }
    
}
