//
//  PagedArray.h
//  Hello Swift Youtube
//
//  Created by Juan on 03/09/14.
//  Based on https://github.com/MrAlek/AWPagedArray (0.2.0) without the NSProxy stuff, which is not compatible with Swift
//  Copyright (c) 2014 IGZ. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const PagedArrayObjectsPerPageMismatchException;

@protocol PagedArrayDelegate;

@interface PagedArray : NSObject

/**
 * The designated initializer for this class
 * Note that the parameters are part of immutable state
 */
- (instancetype)initWithCount:(NSUInteger)count objectsPerPage:(NSUInteger)objectsPerPage;

// - NSArray overrides

- (id)objectAtIndex:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)index;
- (NSUInteger)count;

/**
 * Sets objects for a specific page in the array
 * @param objects The objects in the page
 * @param page The page which these objects should be set for, pages start with index 1
 * @throws PagedArrayObjectsPerPageMismatchException when page size mismatch the initialized objectsPerPage property
 * for any page other than the last.
 */
- (void)setObjects:(NSArray *)objects forPage:(NSUInteger)page;

- (NSUInteger)pageForIndex:(NSUInteger)index;
- (NSIndexSet *)indexSetForPage:(NSUInteger)page;

@property (nonatomic, readonly) NSUInteger objectsPerPage;
@property (nonatomic, readonly) NSUInteger numberOfPages;

/**
 * Contains NSArray instances of pages, backing the data
 */
@property (nonatomic, readonly) NSDictionary *pages;

@property (nonatomic, weak) id<PagedArrayDelegate> delegate;

@end

@protocol PagedArrayDelegate <NSObject>

/**
 * Called when the an object is accessed by index
 *
 * @param pagedArray the paged array being accessed
 * @param index the index in the paged array
 * @param returnObject an id pointer to the object which will be returned to the receiver of the accessor being called.
 *
 * @discussion This delegate method is only called when the paged array is accessed by the objectAtIndex: method or by subscripting.
 * The returnObject pointer can be changed in order to change which object will be returned.
 */
- (void)pagedArray:(PagedArray *)pagedArray willAccessIndex:(NSUInteger)index returnObject:(__autoreleasing id *)returnObject;

@end
