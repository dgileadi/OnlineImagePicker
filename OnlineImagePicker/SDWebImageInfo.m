//
//  SDWebImageInfo.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/19/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "SDWebImageInfo.h"

@implementation SDWebImageInfo

-(id<SDWebImageOperation>) loadThumbnailForTargetSize:(CGSize) size completed:(OnlineImageInfoBlock)onComplete {
    [self loadThumbnailForTargetSize:size options:self.options progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        onComplete(image, error);
    }];
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

-(id<SDWebImageOperation>) loadFullSize:(OnlineImageInfoBlock)onComplete {
    [self loadFullSizeWithOptions:self.options progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        onComplete(image, error);
    }];
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
    return 0;
}

@end
