//
//  ErrorUIHelper.h
//  KAI01
//
//  Created by jtrias on 29/04/14.
//  Copyright (c) 2014 Intelygenz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSONModel/JSONModel.h>
#import <AFNetworking/AFNetworking.h>

@interface ErrorUIHelper : NSObject

+ (NSString *)messageForError:(NSError *)error;
+ (UIAlertView *)alertViewForError:(NSError *)error;

@end
