//
//  SDWebImageInfo.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/19/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SDWebImage/SDWebImageManager.h>
#import "OnlineImageInfo.h"

@interface SDWebImageInfo : NSObject<OnlineImageInfo>

/** Subclasses must implement: return the URL for a thumbnail of the given target size. */
-(NSURL *) thumbnailURLForTargetSize:(CGSize) size;

/** Subclasses must implement: return the URL for the full-size image. */
-(NSURL *) fullSizeURL;

/** Subclasses must implement: return options for downloading the image. */
-(SDWebImageOptions) options;

/** Load a thumbnail of the image that is close to the requested size, customized with the given SDWebImage parameters. */
-(id<SDWebImageOperation>) loadThumbnailForTargetSize:(CGSize) size
                                          options:(SDWebImageOptions)options
                                         progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                        completed:(SDWebImageCompletionWithFinishedBlock)completedBlock;

/** Load the full-size image, customized with the given SDWebImage parameters. */
-(id<SDWebImageOperation>) loadFullSizeWithOptions:(SDWebImageOptions)options
                                      progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                     completed:(SDWebImageCompletionWithFinishedBlock)completedBlock;

@end
