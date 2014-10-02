//
//  FacebookImageInfo.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "FacebookImageInfo.h"
#import <SDWebImage/SDWebImageManager.h>

@implementation FacebookImageInfo

-(id) initWithData:(NSDictionary *)data {
    if (self = [super init])
        self.photoData = data;
    return self;
}

-(NSURL *) thumbnailURLForTargetSize:(CGSize)size {
    CGSize currentSize;
    NSArray *images = [self.photoData objectForKey:@"images"];
    NSURL *thumbnail = nil;
    for (NSDictionary *image in images) {
        NSURL *url = [NSURL URLWithString:[image objectForKey:@"source"]];
        if (!thumbnail)
            url = thumbnail;
        else {
            NSNumber *width = [image objectForKey:@"width"];
            NSNumber *height = [image objectForKey:@"height"];
            CGSize thumbSize = CGSizeMake([width doubleValue], [height doubleValue]);
            if ([self closestSizeTo:size first:currentSize second:thumbSize] == OnlineImageSecondSize)
                thumbnail = url;
        }
    }
    return thumbnail;
}

-(NSURL *) fullsizeURL {
    CGSize currentSize = CGSizeZero;
    NSArray *images = [self.photoData objectForKey:@"images"];
    NSURL *url = nil;
    for (NSDictionary *image in images) {
        NSNumber *width = [image objectForKey:@"width"];
        NSNumber *height = [image objectForKey:@"height"];
        CGSize size = CGSizeMake([width doubleValue], [height doubleValue]);
        if (size.width > currentSize.width || size.height > currentSize.height)
            url = [image objectForKey:@"source"];
    }
    return url;
}

-(id) metadata {
    return self.photoData;
}

@end
