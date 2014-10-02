//
//  SDWebImageInfo.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/19/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "SDWebImageInfo.h"


CGSize CGSizeDifference(CGSize first, CGSize second) {
    return CGSizeMake(ABS(first.width - second.width), ABS(first.height - second.height));
}
CGFloat CGSizeArea(CGSize size) {
    return ABS(size.width) + ABS(size.height);
}


@interface SDWebImageOperationLoad : NSObject<OnlineImageLoad>

@property(nonatomic, readonly) id<SDWebImageOperation> operation;

-(id) initWithOperation:(id<SDWebImageOperation>)operation;

@end

@implementation SDWebImageOperationLoad

-(id) initWithOperation:(id<SDWebImageOperation>)operation {
    if (self = [super init])
        _operation = operation;
    return self;
}

-(void) cancel {
    [self.operation cancel];
}

@end


@implementation SDWebImageInfo

-(OnlineImageSizeChoice) closestSizeTo:(CGSize)desired first:(CGSize)first second:(CGSize)second {
    CGSize firstDifference = CGSizeDifference(first, desired);
    CGSize secondDifference = CGSizeDifference(second, desired);
    return CGSizeArea(firstDifference) < CGSizeArea(secondDifference) ? OnlineImageFirstSize : OnlineImageSecondSize;
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

-(id<OnlineImageLoad>) loadThumbnailForTargetSize:(CGSize)size
                                             progress:(OnlineImageInfoProgressBlock)progressBlock
                                            completed:(OnlineImageInfoCompletedBlock)completedBlock {
    id<SDWebImageOperation> operation = [self loadThumbnailForTargetSize:size options:self.options progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        double progress = receivedSize;
        progress /= expectedSize;
        progressBlock(progress);
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        completedBlock(image, error);
    }];
    return [[SDWebImageOperationLoad alloc] initWithOperation:operation];
}

-(id<SDWebImageOperation>) loadThumbnailForTargetSize:(CGSize) size
                                              options:(SDWebImageOptions)options
                                             progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                            completed:(SDWebImageCompletionWithFinishedBlock)completedBlock {
    return [[SDWebImageManager sharedManager] downloadImageWithURL:[self thumbnailURLForTargetSize:size]
                                                           options:options
                                                          progress:progressBlock
                                                         completed:completedBlock];
}

-(id<OnlineImageLoad>) loadFullSizeWithProgress:(OnlineImageInfoProgressBlock)progressBlock
                                          completed:(OnlineImageInfoCompletedBlock)completedBlock {
    id<SDWebImageOperation> operation = [self loadFullSizeWithOptions:self.options progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        double progress = receivedSize;
        progress /= expectedSize;
        progressBlock(progress);
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        completedBlock(image, error);
    }];
    return [[SDWebImageOperationLoad alloc] initWithOperation:operation];
}

-(id<SDWebImageOperation>) loadFullSizeWithOptions:(SDWebImageOptions)options
                                          progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                         completed:(SDWebImageCompletionWithFinishedBlock)completedBlock {
    return [[SDWebImageManager sharedManager] downloadImageWithURL:self.fullSizeURL
                                                           options:options
                                                          progress:progressBlock
                                                         completed:completedBlock];
}

-(id) metadata {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(NSURL *) thumbnailURLForTargetSize:(CGSize) size {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(NSURL *) fullSizeURL {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(SDWebImageOptions) options {
    return SDWebImageHandleCookies;
}

@end
