//
//  ErrorUIHelper.m
//  KAI01
//
//  Created by jtrias on 29/04/14.
//  Copyright (c) 2014 Intelygenz. All rights reserved.
//

#import "ErrorUIHelper.h"

@implementation ErrorUIHelper

+ (NSString *)messageForError:(NSError *)error {
    
    // Check errors from more app-specific to more general:
    
    // Network errors
    //Error codes for `AFURLResponseSerializationErrorDomain` and `AFURLRequestSerializationErrorDomain` correspond to codes in `NSURLErrorDomain`
    if ([error.domain isEqualToString:NSURLErrorDomain] || [error.domain isEqualToString:AFURLResponseSerializationErrorDomain] || [error.domain isEqualToString:AFURLRequestSerializationErrorDomain]) {
        if (error.code == kCFURLErrorTimedOut) {
            return NSLocalizedString(@"The connection timed out", nil);
            
        } else if (error.code == kCFURLErrorNotConnectedToInternet) {
            return  NSLocalizedString(@"No Internet connection", nil);
            
        } else { // Server sent an unhandled error, server unreachable, URL not found, other connection errors...
            return NSLocalizedString(@"Error trying to connect to the server", nil);
        }
    }
    
    // JSONModel Errors
    if ([error.domain isEqualToString:JSONModelErrorDomain]) {
        return NSLocalizedString(@"Invalid server response", nil); // Ante la duda, la culpa es de los del back ;)
    }
    
    return NSLocalizedString(@"Unknown error", nil);
}

+ (UIAlertView *)alertViewForError:(NSError *)error {
    NSString *message = [ErrorUIHelper messageForError:error];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Accept", nil) otherButtonTitles: nil];
    return alert;
}

// TODO viewControllerForError:(NSError *)error
// ... and other helper methods to print errors

@end
