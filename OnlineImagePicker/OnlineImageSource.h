//
//  OnlineImageSource.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/5/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

@protocol OnlineImageSource;

/**
 * Called when a page of results is returned from an image source.
 * The parameter is an array of OnlineImageInfo objects, up to pageSize in length.
 */
typedef void(^OnlineImageSourceResultsBlock)(NSArray *results);

/**
 * Called when an image source fails to return results due to some error.
 * The parameter is the error that was generated.
 */
typedef void (^OnlineImageSourceFailureBlock)(NSError* error);


/**
 * A protocol for classes that provide information about online images.
 */
@protocol OnlineImageSource <NSObject>

/** The number of results that should be returned with each call to loadImagesWithSuccess:orFailure or nextImagesWithSuccess:orFailure:. */
@property(nonatomic) NSUInteger pageSize;

/** Whether the image source is available. An image source that requires authentication may be unavailable if credentials haven't been provided, for example. */
-(BOOL) isAvailable;

/**
 * Start a new request for images. Only a single page of results is returned. To load further pages of results use nextImagesWithSuccess:orFailure:.
 *
 * @param onSuccess An OnlineImageSourceResultsBlock that is called if the request succeeds, providing an array of OnlineImageInfo results.
 * @param onFailure An OnlineImageSourceFailureBlock that is called if the request fails, providing the error that occurred.
 */
-(void) loadImagesWithSuccess:(OnlineImageSourceResultsBlock) onSuccess orFailure:(OnlineImageSourceFailureBlock) onFailure;

/**
 * Continue a previous request for images, providing the next page of results.
 *
 * @param onSuccess An OnlineImageSourceResultsBlock that is called if the request succeeds, providing an array of OnlineImageInfo results.
 * @param onFailure An OnlineImageSourceFailureBlock that is called if the request fails, providing the error that occurred.
 */
-(void) nextImagesWithSuccess:(OnlineImageSourceResultsBlock) onSuccess orFailure:(OnlineImageSourceFailureBlock) onFailure;

@end