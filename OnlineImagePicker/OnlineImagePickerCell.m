//
//  OnlineImagePickerCell.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/24/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "OnlineImagePickerCell.h"

@implementation OnlineImagePickerCell

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}

@end
