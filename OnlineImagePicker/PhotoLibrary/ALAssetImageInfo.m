//
//  ALAssetImageInfo.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/19/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "ALAssetImageInfo.h"
#import <UIKit/UIKit.h>

@implementation ALAssetImageInfo

-(id) initWithAsset:(ALAsset *)asset {
    if (self = [super init])
        self.asset = asset;
    return self;
}

-(id<OnlineImageLoad>) loadThumbnailForTargetSize:(CGSize)size
                                         progress:(OnlineImageInfoProgressBlock)progressBlock
                                        completed:(OnlineImageInfoCompletedBlock)completedBlock {
    CGImageRef thumbnailImageRef = [self.asset thumbnail];
    UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    completedBlock(thumbnail, nil);
    return nil;
}

-(id<OnlineImageLoad>) loadFullSizeWithProgress:(OnlineImageInfoProgressBlock)progressBlock
                                      completed:(OnlineImageInfoCompletedBlock)completedBlock {
    ALAssetRepresentation *representation = [self.asset defaultRepresentation];
    UIImage *image = [UIImage imageWithCGImage:[representation fullResolutionImage]
                                         scale:[representation scale]
                                   orientation:UIImageOrientationUp];
    completedBlock(image, nil);
    return nil;
}

-(id) metadata {
    return self.asset;
}

@end
