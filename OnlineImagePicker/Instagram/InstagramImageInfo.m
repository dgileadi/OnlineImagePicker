//
//  InstagramImageInfo.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/19/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "InstagramImageInfo.h"
#import <SDWebImage/SDWebImageManager.h>

CGSize CGSizeDifference(CGSize first, CGSize second) {
    return CGSizeMake(ABS(first.width - second.width), ABS(first.height - second.height));
}
CGFloat CGSizeArea(CGSize size) {
    return ABS(size.width) + ABS(size.height);
}

@implementation InstagramImageInfo

-(id) initWithMedia:(InstagramMedia *)media {
    if (self = [super init])
        self.instagramMedia = media;
    return self;
}

-(NSURL *) thumbnailURLForTargetSize:(CGSize)size {
    CGSize currentSize;
    NSURL *thumbnail = [self bestURLForTargetSize:size withSize:self.instagramMedia.thumbnailFrameSize andURL:self.instagramMedia.thumbnailURL currentSize:&currentSize currentURL:nil];
    thumbnail = [self bestURLForTargetSize:size withSize:self.instagramMedia.lowResolutionImageFrameSize andURL:self.instagramMedia.lowResolutionImageURL currentSize:&currentSize currentURL:nil];
    thumbnail = [self bestURLForTargetSize:size withSize:self.instagramMedia.standardResolutionImageFrameSize andURL:self.instagramMedia.standardResolutionImageURL currentSize:&currentSize currentURL:nil];
    return thumbnail;
}

-(NSURL *) bestURLForTargetSize:(CGSize)desired withSize:(CGSize)size andURL:(NSURL *)url currentSize:(CGSize *)currentSize currentURL:(NSURL *)currentURL {
    if (!currentURL) {
        *currentSize = size;
        return url;
    } else {
        CGSize newDifference = CGSizeDifference(size, desired);
        CGSize oldDifference = CGSizeDifference(*currentSize, desired);
        if (CGSizeArea(newDifference) < CGSizeArea(oldDifference)) {
            *currentSize = size;
            return url;
        }
    }
}

-(NSURL *) fullsizeURL {
    return self.instagramMedia.standardResolutionImageURL;
}

-(id) metadata {
    return self.instagramMedia;
}

@end
