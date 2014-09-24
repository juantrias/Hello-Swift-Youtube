//
//  YUItemJSONModel.h
//  Hello Swift
//
//  Created by Juan on 11/07/14.
//  Copyright (c) 2014 IGZ. All rights reserved.
//

#import "JSONModel.h"
#import "YUItemIdJSONModel.h"
#import "YUSnippetJSONModel.h"

@protocol YUItemJSONModel
@end

@interface YUItemJSONModel : JSONModel

@property (strong, atomic) YUItemIdJSONModel *id;
@property (strong, atomic) YUSnippetJSONModel *snippet;

@end
