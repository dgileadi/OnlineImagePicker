//
//  OnlineImagePickerCell.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/24/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "OnlineImagePickerCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <M13ProgressSuite/M13ProgressViewRing.h>

@implementation OnlineImagePickerCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.progressView.frame = [self progressFrame];
    self.imageView.frame = self.bounds;
}

-(CGRect) progressFrame {
    CGFloat progressWidth = self.bounds.size.width / 2;
    return CGRectMake((self.bounds.size.width - progressWidth) / 2, (self.bounds.size.height - progressWidth) / 2, progressWidth, progressWidth);
}

-(M13ProgressView *) progressView {
    if (!_progressView) {
        [self setProgressView:[[M13ProgressViewRing alloc] initWithFrame:[self progressFrame]]];
        _progressView.primaryColor = self.tintColor;
        [self addSubview:_progressView];
    }
    return _progressView;
}

-(UIImageView *) imageView {
    if (!_imageView) {
        [self setImageView:[[UIImageView alloc] initWithFrame:self.bounds]];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
    }
    return _imageView;
}

-(void) setImageInfo:(id<OnlineImageInfo>)imageInfo {
    BOOL same = _imageInfo == imageInfo;
    _imageInfo = imageInfo;
    if (!imageInfo)
        [self showIndeterminateProgress];
    else if (!same)
        [self loadImageAtScale:self.scale];
}

-(void) showIndeterminateProgress {
    self.progressView.hidden = NO;
    self.imageView.hidden = YES;
    self.progressView.indeterminate = YES;
}

-(void) setProgress:(CGFloat)progress {
    self.progressView.hidden = NO;
    self.imageView.hidden = YES;
    [self.progressView setProgress:progress animated:YES];
}

-(void) loadImageAtScale:(CGFloat) scale {
    [self.imageView sd_cancelCurrentImageLoad];
    [self setImage:nil];
    _startedLoad = [NSDate date];
    
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
            _finishedLoad = [NSDate date];
            if (image)
                [wself setImage:image];
            else
                self.progressView.hidden = YES;
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
