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

@property (strong, atomic) YUUrlJSONModel *defaultThumb; //default is a reserved word in Objective C
@property (strong, atomic) YUUrlJSONModel *medium;
@property (strong, atomic) YUUrlJSONModel *high;

@end
