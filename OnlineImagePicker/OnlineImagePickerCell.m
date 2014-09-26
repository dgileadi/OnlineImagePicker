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
    if (!self.imageView) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
    }
    
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
}

@end
