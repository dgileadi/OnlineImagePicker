//
//  OnlineImageInfo.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/11/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <SDWebImage/SDWebImageManager.h>


/**
 * Called when an image finishes downloading or encounters an error.
 */
typedef void(^OnlineImageInfoBlock)(UIImage *image, NSError *error);


/**
 * Holds information about an online image.
 */
@protocol OnlineImageInfo <NSObject>

/** Load a thumbnail of the image that is close to the requested size. */
-(id<SDWebImageOperation>) loadThumbnailForTargetSize:(CGSize) size completed:(OnlineImageInfoBlock)onComplete;

/** Load a thumbnail of the image that is close to the requested size, customized with the given SDWebImage parameters. */
-(id<SDWebImageOperation>) loadThumbnailForTargetSize:(CGSize) size
                                              options:(SDWebImageOptions)options
                                             progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                            completed:(SDWebImageCompletionWithFinishedBlock)completedBlock;

/** Load the full-size image. */
-(id<SDWebImageOperation>) loadFullSize:(OnlineImageInfoBlock)onComplete;

/** Load the full-size image, customized with the given SDWebImage parameters. */
-(id<SDWebImageOperation>) loadFullSizeWithOptions:(SDWebImageOptions)options
                                          progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                         completed:(SDWebImageCompletionWithFinishedBlock)completedBlock;

/** A class-specific object that provides metadata about the image. */
-(id) metadata;

@end