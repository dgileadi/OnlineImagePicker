//
//  FlickrImageInfo.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/6/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "FlickrImageInfo.h"
#import <FlickrKit/FlickrKit.h>

@implementation FlickrImageInfo

-(id) initWithData:(NSDictionary *)data {
    if (self = [super init])
        self.photoData = data;
    return self;
}

-(NSURL *) thumbnailURLForTargetSize:(CGSize)size {
    if ([self closestSizeTo:size first:CGSizeMake(75, 75) second:CGSizeMake(150, 150)] == OnlineImageFirstSize)
        return [[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeSmallSquare75 fromPhotoDictionary:self.photoData];
    else
        return [[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeLargeSquare150 fromPhotoDictionary:self.photoData];
}

-(NSURL *) fullsizeURL {
    return [[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeOriginal fromPhotoDictionary:self.photoData];
}

-(id) metadata {
    return self.photoData;
}

@end
