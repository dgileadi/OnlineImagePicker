//
//  OnlineImagePickerCell.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/24/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OnlineImageInfo.h"

@interface OnlineImagePickerCell : UICollectionViewCell

@property(nonatomic) id<OnlineImageInfo> imageInfo;
@property(nonatomic) IBOutlet UIImageView *imageView;

@end
