//
//  PagedScrollHelper.m
//  Hello Swift Youtube
//
//  Created by Juan on 08/09/14.
//  Copyright (c) 2014 IGZ. All rights reserved.
//

#import "PagedScrollHelper.h"

@interface PagedScrollHelper ()

@property (assign, nonatomic) NSUInteger totalCount;
@property (assign, nonatomic) NSUInteger objectsPerPage;

@end

@implementation PagedScrollHelper

#pragma mark - Public methods
- (instancetype)initWithCount:(NSUInteger)count objectsPerPage:(NSUInteger)objectsPerPage {
    
    self.totalCount = count;
    self.objectsPerPage = objectsPerPage;
    
    return self;
}

- (NSUInteger)pageForIndex:(NSUInteger)index {
    return index/_objectsPerPage + 1;
}

- (NSIndexSet *)indexSetForPage:(NSUInteger)page {
    NSUInteger rangeLength = _objectsPerPage;
    if (page == [self numberOfPages]) {
        rangeLength = (_totalCount % _objectsPerPage) ?: _objectsPerPage;
    }
    return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange((page - 1) * _objectsPerPage, rangeLength)];
}

- (NSUInteger)numberOfPages {
    return ceil((CGFloat)self.totalCount / self.objectsPerPage);
}

@end