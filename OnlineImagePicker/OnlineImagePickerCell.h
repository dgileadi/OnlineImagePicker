//
//  OnlineImagePickerCell.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/24/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OnlineImageInfo.h"
#import <M13ProgressSuite/M13ProgressView.h>

/**
 * A cell that holds a progress bar and an image thumbnail.
 */
@interface OnlineImagePickerCell : UICollectionViewCell

/** Information about the image. */
@property(nonatomic) id<OnlineImageInfo> imageInfo;

/** A view to hold the image. */
@property(nonatomic) IBOutlet UIImageView *imageView;

/** A progress view while the image is loading. */
@property(nonatomic) IBOutlet M13ProgressView *progressView;

/** The point in time when the image's load started. */
@property(nonatomic, readonly) NSDate *startedLoad;

/** The point in time when the image finished loading. */
@property(nonatomic, readonly) NSDate *finishedLoad;

/** Show indeterminate progress. */
-(void) showIndeterminateProgress;

/** Set the progress to display while loading the image. */
-(void) setProgress:(CGFloat)progress;

/**
 * Load an image.
 *
 * @param scale Should be the device's scale.
 */
-(void) loadImageAtScale:(CGFloat)scale;

/** Set an image for display, hiding the progress bar. To set a temporary image use `imageView.image` instead. */
-(void) setImage:(UIImage *)image;

@end
