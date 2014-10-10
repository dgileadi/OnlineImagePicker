//
//  OnlineImageInfo.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/11/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>


/**
 * Called while an image is being loaded to report its progress.
 */
typedef void(^OnlineImageInfoProgressBlock)(double progress);

/**
 * Called when an image finishes downloading or encounters an error.
 */
typedef void(^OnlineImageInfoCompletedBlock)(UIImage *image, NSError *error);


/**
 * Allows canceling a load operation.
 */
@protocol OnlineImageLoad <NSObject>

-(void) cancel;

@end


/**
 * Holds information about an online image.
 */
@protocol OnlineImageInfo <NSObject>

/** Load a thumbnail of the image that is close to the requested size. */
-(id<OnlineImageLoad>) loadThumbnailForTargetSize:(CGSize)size
                                             progress:(OnlineImageInfoProgressBlock)progressBlock
                                            completed:(OnlineImageInfoCompletedBlock)completedBlock;

/** Load the full-size image. */
-(id<OnlineImageLoad>) loadFullSizeWithProgress:(OnlineImageInfoProgressBlock)progressBlock
                                          completed:(OnlineImageInfoCompletedBlock)completedBlock;

/** A class-specific object that provides metadata about the image. */
@property(nonatomic, readonly) id metadata;

@end