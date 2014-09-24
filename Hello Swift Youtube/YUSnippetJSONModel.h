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

@property (strong, atomic) NSString *title;
@property (strong, atomic) NSString *descr;
@property (strong, atomic) YUThumbnailsJSONModel *thumbnails;
@property (strong, atomic) NSString *channelTitle;

@end
