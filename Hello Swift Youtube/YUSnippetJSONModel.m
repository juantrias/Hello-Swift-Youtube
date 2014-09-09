//
//  YUSnippetJSONModel.m
//  Hello Swift
//
//  Created by Juan on 11/07/14.
//  Copyright (c) 2014 IGZ. All rights reserved.
//

#import "YUSnippetJSONModel.h"

@implementation YUSnippetJSONModel

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"description": @"descr"}];
}
            
@end
