//
//  OnlineImagePickerCell.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/24/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OnlineImageInfo.h"
#import <M13ProgressSuite/M13ProgressViewPie.h>

@interface OnlineImagePickerCell : UICollectionViewCell

@property(nonatomic) id<OnlineImageInfo> imageInfo;
@property(nonatomic) IBOutlet UIImageView *imageView;
@property(nonatomic) IBOutlet M13ProgressViewPie *progressView;

-(void) setProgress:(CGFloat)progress;
-(void) loadImageAtScale:(CGFloat)scale;
-(void) setImage:(UIImage *)image;

@end
