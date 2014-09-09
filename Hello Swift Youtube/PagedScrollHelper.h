//
//  PagedScrollHelper.h
//  Hello Swift Youtube
//
//  Created by Juan on 08/09/14.
//  Copyright (c) 2014 IGZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface PagedScrollHelper : NSObject

- (instancetype)initWithCount:(NSUInteger)count objectsPerPage:(NSUInteger)objectsPerPage;
- (NSUInteger)pageForIndex:(NSUInteger)index;
- (NSIndexSet *)indexSetForPage:(NSUInteger)page;
- (NSUInteger)numberOfPages;

@end
