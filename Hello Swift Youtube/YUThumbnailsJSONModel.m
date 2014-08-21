//
//  YUThumbnailsJSONModel.m
//  Hello Swift
//
//  Created by Juan on 11/07/14.
//  Copyright (c) 2014 IGZ. All rights reserved.
//

#import "YUThumbnailsJSONModel.h"

@implementation YUThumbnailsJSONModel

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"default": @"defaultThumb"}];
}

@end
