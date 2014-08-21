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

@property (strong, nonatomic) YUPageInfoJSONModel *pageInfo;
@property (strong, nonatomic) NSString *nextPageToken;
@property (strong, nonatomic) NSArray<YUItemJSONModel> *items;

@end
