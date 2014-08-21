//
//  YUSnippetJSONModel.h
//  Hello Swift
//
//  Created by Juan on 11/07/14.
//  Copyright (c) 2014 IGZ. All rights reserved.
//

#import "JSONModel.h"
#import "YUThumbnailsJSONModel.h"

@interface YUSnippetJSONModel : JSONModel

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) YUThumbnailsJSONModel *thumbnails;
@property (strong, nonatomic) NSString *channelTitle;

@end
