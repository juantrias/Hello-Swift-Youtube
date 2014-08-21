//
//  YUThumbnailsJSONModel.h
//  Hello Swift
//
//  Created by Juan on 11/07/14.
//  Copyright (c) 2014 IGZ. All rights reserved.
//

#import "JSONModel.h"
#import "YUUrlJSONModel.h"

@interface YUThumbnailsJSONModel : JSONModel

@property (strong, nonatomic) YUUrlJSONModel *defaultThumb; //default is a reserved word in Objective C
@property (strong, nonatomic) YUUrlJSONModel *medium;
@property (strong, nonatomic) YUUrlJSONModel *high;

@end
