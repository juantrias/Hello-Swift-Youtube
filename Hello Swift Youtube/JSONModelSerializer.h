//
//  JSONModelSerializer.h
//  KAI01
//
//  Created by Juan on 24/04/14.
//  Copyright (c) 2014 Intelygenz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import "DLog.h"

@interface JSONModelSerializer : AFHTTPResponseSerializer

+ (instancetype)serializerForClass:(Class) clazz;

@end
