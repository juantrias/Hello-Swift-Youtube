//
//  VideoDto.swift
//  Hello Swift Youtube
//
//  Created by Juan on 04/09/14.
//  Copyright (c) 2014 IGZ. All rights reserved.
//

import Foundation

public class VideoDto: RLMObject {
    dynamic var videoId: String
    dynamic var title: String
    dynamic var descr: String
    dynamic var thumbnail: String
    
    init(itemJsonModel: YUItemJSONModel) {
        videoId = itemJsonModel.id.videoId
        title = itemJsonModel.snippet.title
        descr = itemJsonModel.snippet.descr
        thumbnail = itemJsonModel.snippet.thumbnails.defaultThumb.url
        super.init()
    }
}
