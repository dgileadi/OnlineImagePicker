//
//  FacebookImageInfo.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "FacebookImageInfo.h"
#import <SDWebImage/SDWebImageManager.h>

CGSize CGSizeDifference(CGSize first, CGSize second) {
    return CGSizeMake(ABS(first.width - second.width), ABS(first.height - second.height));
}
CGFloat CGSizeArea(CGSize size) {
    return ABS(size.width) + ABS(size.height);
}

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
        NSNumber *width = [image objectForKey:@"width"];
        NSNumber *height = [image objectForKey:@"height"];
        CGSize size = CGSizeMake([width doubleValue], [height doubleValue]);
        thumbnail = [self bestURLForTargetSize:size withSize:size andURL:[image objectForKey:@"source"] currentSize:&currentSize];
    }
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
        } else
            return currentURL;
    }
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
