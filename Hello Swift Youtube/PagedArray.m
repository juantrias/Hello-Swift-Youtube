//
//  PagedArray.m
//  Hello Swift Youtube
//
//  Created by Juan on 03/09/14.
//  Copyright (c) 2014 IGZ. All rights reserved.
//

#import "PagedArray.h"
#import <CoreGraphics/CoreGraphics.h>

NSString *const PagedArrayObjectsPerPageMismatchException = @"PagedArrayObjectsPerPageMismatchException";

@implementation PagedArray {
    NSUInteger _totalCount;
    NSUInteger _objectsPerPage;
    NSMutableDictionary *_pages;
    
    BOOL _needsUpdateProxiedArray;
    NSArray *_proxiedArray;
}

#pragma mark - Public methods
- (instancetype)initWithCount:(NSUInteger)count objectsPerPage:(NSUInteger)objectsPerPage {
    
    _totalCount = count;
    _objectsPerPage = objectsPerPage;
    _pages = [[NSMutableDictionary alloc] initWithCapacity:[self numberOfPages]];
    
    return self;
}
- (void)setObjects:(NSArray *)objects forPage:(NSUInteger)page {
    
    if (objects.count == _objectsPerPage || page == self.numberOfPages) {
        
        _pages[@(page)] = objects;
        _needsUpdateProxiedArray = YES;
    } else {
        [NSException raise:PagedArrayObjectsPerPageMismatchException format:@"Expected object count per page: %ld received: %ld", (unsigned long)_objectsPerPage, (unsigned long)objects.count];
    }
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
- (NSDictionary *)pages {
    return _pages;
}

#pragma mark - NSArray overrides
- (id)objectAtIndex:(NSUInteger)index {
    
    id object = [[self _proxiedArray] objectAtIndex:index];
    
    [self.delegate pagedArray:self
              willAccessIndex:index
                 returnObject:&object];
    
    return object;
}
- (id)objectAtIndexedSubscript:(NSUInteger)index {
    return [self objectAtIndex:index];
}

- (NSUInteger)count {
    return [[self _proxiedArray] count];
}

#pragma mark - Private methods
- (NSUInteger)numberOfPages {
    return ceil((CGFloat)_totalCount/_objectsPerPage);
}
- (NSArray *)_proxiedArray {
    
    if (!_proxiedArray || _needsUpdateProxiedArray) {
        
        [self _generateProxiedArray];
        _needsUpdateProxiedArray = NO;
    }
    
    return _proxiedArray;
}
- (void)_generateProxiedArray {
    
    NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:_totalCount];
    
    for (NSInteger pageIndex = 1; pageIndex <= [self numberOfPages]; pageIndex++) {
        
        NSArray *page = _pages[@(pageIndex)];
        if (!page) page = [self _placeholdersForPage:pageIndex];
        
        [objects addObjectsFromArray:page];
    }
    
    _proxiedArray = objects;
}
- (NSArray *)_placeholdersForPage:(NSUInteger)page {
    
    NSMutableArray *placeholders = [[NSMutableArray alloc] initWithCapacity:_objectsPerPage];
    
    NSUInteger pageLimit = [[self indexSetForPage:page] count];
    for (NSUInteger i = 0; i < pageLimit; ++i) {
        [placeholders addObject:[NSNull null]];
    }
    
    return placeholders;
}

@end
