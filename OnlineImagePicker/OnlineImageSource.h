//
//  OnlineImageSource.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/5/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "OnlineImageAccount.h"


/**
 * Called when a page of results is returned from an image source.
 *
 * @param results An array of OnlineImageInfo objects, up to the requested count in length. If empty or `nil` and error is `nil` then no more results are available.
 * @param error An error that occurred or `nil`.
 */
typedef void(^OnlineImageSourceResultsBlock)(NSArray *results, NSError *error);


/**
 * A protocol for classes that provide information about online images.
 */
@protocol OnlineImageSource <NSObject>

/** Returns the account required by this OnlineImageSource or `nil` if no user account is required. */
@property(nonatomic, readonly) id<OnlineImageAccount> account;

/** Whether the image source is available. An image source that requires authentication may be unavailable if credentials haven't been provided, for example. */
@property(nonatomic, readonly) BOOL isAvailable;

/** Returns whether any more images are available. Should return YES if the source doesn't know if it has images yet. */
@property(nonatomic, readonly) BOOL hasMoreImages;

/** Returns YES if a request for images has started that hasn't been replied to yet. */
@property(nonatomic, readonly) BOOL isLoading;

/** If isLoading returns YES, returns the time that the load started. */
@property(nonatomic, readonly) NSDate *loadStartTime;

/**
 * Start a new request for images. Only a single page of results is returned. To load further pages of results use nextImages:.
 *
 * @param resultsBlock An OnlineImageSourceResultsBlock that is called when the request completes, providing an array of OnlineImageInfo results and/or an error.
 */
-(void) load:(NSUInteger)count images:(OnlineImageSourceResultsBlock)resultsBlock;

/**
 * Continue a previous request for images, providing the next page of results.
 *
 * @param resultsBlock An OnlineImageSourceResultsBlock that is called when the request completes, providing an array of OnlineImageInfo results and/or an error.
 */
-(void) next:(NSUInteger)count images:(OnlineImageSourceResultsBlock)resultsBlock;

@end