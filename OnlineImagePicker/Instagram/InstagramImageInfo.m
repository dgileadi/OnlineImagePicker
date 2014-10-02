//
//  InstagramImageInfo.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/19/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "InstagramImageInfo.h"
#import <SDWebImage/SDWebImageManager.h>

@implementation InstagramImageInfo

-(id) initWithMedia:(InstagramMedia *)media {
    if (self = [super init])
        self.instagramMedia = media;
    return self;
}

-(NSURL *) thumbnailURLForTargetSize:(CGSize)size {
    CGSize currentSize = self.instagramMedia.thumbnailFrameSize;
    NSURL *thumbnail = self.instagramMedia.thumbnailURL;
    if ([self closestSizeTo:size first:currentSize second:self.instagramMedia.lowResolutionImageFrameSize] == OnlineImageSecondSize) {
        currentSize = self.instagramMedia.lowResolutionImageFrameSize;
        thumbnail = self.instagramMedia.lowResolutionImageURL;
    }
    if ([self closestSizeTo:size first:currentSize second:self.instagramMedia.standardResolutionImageFrameSize] == OnlineImageSecondSize)
        thumbnail = self.instagramMedia.standardResolutionImageURL;
    return thumbnail;
}

-(NSURL *) fullsizeURL {
    return self.instagramMedia.standardResolutionImageURL;
}

-(id) metadata {
    return self.instagramMedia;
}

@end
