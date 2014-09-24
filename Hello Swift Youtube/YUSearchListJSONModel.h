//
//  YUSearchListJSONModel.h
//  Hello Swift
//
//  Created by Juan on 11/07/14.
//  Copyright (c) 2014 IGZ. All rights reserved.
//

#import "JSONModel.h"
#import "YUItemJSONModel.h"
#import "YUPageInfoJSONModel.h"

@interface YUSearchListJSONModel : JSONModel

@property (strong, atomic) YUPageInfoJSONModel *pageInfo;
@property (strong, atomic) NSString<Optional> *nextPageToken;
@property (strong, atomic) NSString<Optional> *prevPageToken;
@property (strong, atomic) NSArray<YUItemJSONModel> *items;

@end
