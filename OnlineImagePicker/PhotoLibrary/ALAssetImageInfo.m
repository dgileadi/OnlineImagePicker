//
//  ALAssetImageInfo.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/19/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "ALAssetImageInfo.h"

@implementation ALAssetImageInfo

-(id) initWithAsset:(ALAsset *)asset {
    if (self = [super init])
        self.asset = asset;
    return self;
}

-(NSURL *) thumbnailURL {
    return self.asset.thumbnail;
}

-(id) metadata {
    return asset;
}

@end
