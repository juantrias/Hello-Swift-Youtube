//
//  YUPageInfoJSONModel.h
//  Hello Swift
//
//  Created by Juan on 11/07/14.
//  Copyright (c) 2014 IGZ. All rights reserved.
//

#import "JSONModel.h"

@interface YUPageInfoJSONModel : JSONModel

@property (strong, nonatomic) NSNumber *totalResults;
@property (strong, nonatomic) NSNumber *resultsPerPage;

@end
