//
//  YUPageInfoJSONModel.h
//  Hello Swift
//
//  Created by Juan on 11/07/14.
//  Copyright (c) 2014 IGZ. All rights reserved.
//

#import "JSONModel.h"

@interface YUPageInfoJSONModel : JSONModel

@property (strong, atomic) NSNumber *totalResults;
@property (strong, atomic) NSNumber *resultsPerPage;

@end
