//
//  OnlineImagePickerCell.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/24/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "OnlineImagePickerCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation OnlineImagePickerCell

- (void)layoutSubviews {
    CGFloat progressWidth = self.bounds.size.width / 2;
    CGRect progressFrame = CGRectMake(progressWidth / 2, (self.bounds.size.height - progressWidth) / 2, progressWidth, progressWidth);
    
    if (!self.progressView) {
        self.progressView = [[M13ProgressViewPie alloc] initWithFrame:progressFrame];
        self.progressView.primaryColor = self.tintColor;
        [self addSubview:self.progressView];
    }
    if (!self.imageView) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
    }
    
    [super layoutSubviews];
    
    self.progressView.frame = progressFrame;
    self.imageView.frame = self.bounds;
}

-(void) setProgress:(CGFloat)progress {
    self.progressView.hidden = NO;
    self.imageView.hidden = YES;
    [self.progressView setProgress:progress animated:YES];
}

-(void) loadImageAtScale:(CGFloat) scale {
    [self.imageView sd_cancelCurrentImageLoad];
    [self setImage:nil];
    
    CGSize size = self.bounds.size;
    if (scale > 1)
        size = CGSizeMake(size.width * scale, size.height * scale);
    
    __weak OnlineImagePickerCell *wself = self;
    [self.imageInfo loadThumbnailForTargetSize:size progress:^(double progress) {
        if (!wself)
            return;
        dispatch_main_sync_safe(^{
            [wself setProgress:progress];
        });
    } completed:^(UIImage *image, NSError *error) {
        if (!wself)
            return;
        dispatch_main_sync_safe(^{
            if (image)
                [wself setImage:image];
            if (error) {
// TODO: what?
                
                
                NSLog(@"Error loading image: %@", error);
            }
        });
    }];
}

-(void) setImage:(UIImage *)image {
    self.progressView.hidden = image != nil;
    self.imageView.hidden = image == nil;
    self.imageView.image = image;
    [self setNeedsLayout];
}

@end
