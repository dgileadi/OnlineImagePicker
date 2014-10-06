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

/** The scale to load thumbnails at, useful for retina displays. */
@property(nonatomic) CGFloat scale;

/** A view to hold the image. */
@property(nonatomic) IBOutlet UIImageView *imageView;

/** A progress view while the image is loading. */
@property(nonatomic) IBOutlet M13ProgressView *progressView;

/** The point in time when the image's load started. */
@property(nonatomic, readonly) NSDate *startedLoad;

/** The point in time when the image finished loading. */
@property(nonatomic, readonly) NSDate *finishedLoad;

@end
