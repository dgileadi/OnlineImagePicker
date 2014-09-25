//
//  PhotoLibraryImageInfo.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/19/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#if __IPHONE_8_0

#import "PhotoLibraryImageInfo.h"
#import "PhotoLibraryRequestOperation.h"

@implementation PhotoLibraryImageInfo

-(id) initWithAsset:(PHAsset *)asset {
    if (self = [super init])
        self.asset = asset;
    return self;
}

-(id<OnlineImageLoad>) loadThumbnailForTargetSize:(CGSize)size
                                         progress:(OnlineImageInfoProgressBlock)progressBlock
                                        completed:(OnlineImageInfoCompletedBlock)completedBlock {
    PHImageRequestOptions *photoOptions = [[PHImageRequestOptions alloc] init];
    photoOptions.version = PHImageRequestOptionsVersionCurrent;
    photoOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    if (progressBlock) {
        photoOptions.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            if (progressBlock)
                progressBlock(progress);
        };
    }
    PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageForAsset:self.asset
                                                                            targetSize:size
                                                                           contentMode:PHImageContentModeAspectFill
                                                                               options:photoOptions
                                                                         resultHandler:^(UIImage *result, NSDictionary *info) {
        NSError *error = [info objectForKey:PHImageErrorKey];
        completedBlock(result, error);
    }];
    return [[PhotoLibraryRequestOperation alloc] initWithRequestID:requestID];
}

-(id<OnlineImageLoad>) loadFullSizeWithProgress:(OnlineImageInfoProgressBlock)progressBlock
                                      completed:(OnlineImageInfoCompletedBlock)completedBlock {
    PHImageRequestOptions *photoOptions = [[PHImageRequestOptions alloc] init];
    photoOptions.version = PHImageRequestOptionsVersionCurrent;
    photoOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    photoOptions.resizeMode = PHImageRequestOptionsResizeModeNone;
    if (progressBlock) {
        photoOptions.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            if (progressBlock)
                progressBlock(progress);
        };
    }
    PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageDataForAsset:self.asset
                                                                                   options:photoOptions
                                                                             resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        NSError *error = [info objectForKey:PHImageErrorKey];
        UIImage *image = [UIImage imageWithData:imageData];
        completedBlock(image, error);
    }];
    return [[PhotoLibraryRequestOperation alloc] initWithRequestID:requestID];
}

-(id) metadata {
    return self.asset;
}

@end

#endif