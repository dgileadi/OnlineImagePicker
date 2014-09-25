//
//  OnlineImageManager.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/10/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnlineImageSource.h"

/**
 * Called when a page of results is returned from an image source.
 * The parameters are an array of OnlineImageInfo objects, up to pageSize in length, and the source of the results.
 */
typedef void(^OnlineImageResultsBlock)(NSArray *results, id<OnlineImageSource> source);

/**
 * Called when an image source fails to return results due to some error.
 * The parameters are the error that was generated and the source of the error.
 */
typedef void (^OnlineImageFailureBlock)(NSError* error, id<OnlineImageSource> source);


/**
 * A step lower than OnlineImagePicker, this class loads image information from various sources and returns it.
 * Loading and displaying the images is left to classes that use this one.
 */
@interface OnlineImageManager : NSObject

/**
 * The number of results that should be returned with each call to loadImagesWithSuccess:orFailure or nextImagesWithSuccess:orFailure:.
 */
@property(nonatomic) NSUInteger pageSize;

/**
 * Initialize this manager with the given objects that implement the OnlineImageSource protocol.
 */
-(id) initWithImageSources:(NSArray *)imageSources;

/**
 * An array of objects that implement the OnlineImageSource protocol, which will be queried for images. Inactive sources will be ignored.
 */
-(NSArray *)imageSources;

/**
 * Add an object that implements the OnlineImageSource protocol, which will be queried for images if active.
 */
-(void) addImageSource:(id<OnlineImageSource>)source;

/**
 * Add objects that implement the OnlineImageSource protocol from an array.
 */
-(void) addImageSourcesFromArray:(NSArray *)sources;

/**
 * Remove an object from imageSources.
 */
-(void) removeImageSource:(id<OnlineImageSource>)source;

/**
 * Remove all objects from imageSources.
 */
-(void) removeAllImageSources;

/**
 * Start a new request for images. Only a single page of results is returned. To load further pages of results use nextImagesWithSuccess:orFailure:.
 *
 * @param onSuccess An OnlineImageResultsBlock that is called if the request succeeds, providing an array of OnlineImageInfo results.
 * If there are multiple image sources then this block may be called multiple times, once for each source.
 * @param onFailure An OnlineImageFailureBlock that is called if the request fails, providing the error that occurred.
 * If there are multiple image sources then this block may be called multiple times, once for each source.
 */
-(void) loadImagesWithSuccess:(OnlineImageResultsBlock)onSuccess orFailure:(OnlineImageFailureBlock)onFailure;

/**
 * Continue a previous request for images, providing the next page of results.
 *
 * @param onSuccess An OnlineImageResultsBlock that is called if the request succeeds, providing an array of OnlineImageInfo results.
 * If there are multiple image sources then this block may be called multiple times, once for each source.
 * @param onFailure An OnlineImageFailureBlock that is called if the request fails, providing the error that occurred.
 * If there are multiple image sources then this block may be called multiple times, once for each source.
 */
-(void) nextImagesWithSuccess:(OnlineImageResultsBlock)onSuccess orFailure:(OnlineImageFailureBlock)onFailure;

@end
