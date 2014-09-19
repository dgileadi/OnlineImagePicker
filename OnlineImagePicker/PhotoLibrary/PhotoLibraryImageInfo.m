//
//  PhotoLibraryImageInfo.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/19/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "PhotoLibraryImageInfo.h"

@implementation PhotoLibraryImageInfo

-(id) initWithAsset:(ALAsset *)asset {
    if (self = [super init])
        self.asset = asset;
    return self;
}

-(NSURL *) thumbnailURLForTargetSize:(CGSize)size {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    [[PHImageManager defaultManager] requestImageForAsset:self.asset targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        <#code#>
    }];
}

-(id) metadata {
    return asset;
}

@end
