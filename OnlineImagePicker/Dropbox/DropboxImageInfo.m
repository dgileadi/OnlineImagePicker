//
//  DropboxImageInfo.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "DropboxImageInfo.h"
#import <SDWebImage/SDWebImageManager.h>


@interface DropboxImageLoad : NSObject <OnlineImageLoad, DBRestClientDelegate>

@property(nonatomic, readonly) DBRestClient *restClient;
@property(nonatomic, readonly) NSString *path;
@property(nonatomic, readonly, strong) OnlineImageInfoProgressBlock progressBlock;
@property(nonatomic, readonly, strong) OnlineImageInfoCompletedBlock completedBlock;

-(id) initWithPath:(NSString *)path progress:(OnlineImageInfoProgressBlock)progressBlock completed:(OnlineImageInfoCompletedBlock)completedBlock;

@end

@implementation DropboxImageLoad

-(id) initWithPath:(NSString *)path progress:(OnlineImageInfoProgressBlock)progressBlock completed:(OnlineImageInfoCompletedBlock)completedBlock {
    if (self = [super init]) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
        _path = path;
        _progressBlock = progressBlock;
        _completedBlock = completedBlock;
    }
    return self;
}

-(void) startLoad {
    NSString *extension = [self.path pathExtension];
    NSString *destinationPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [[NSUUID UUID] UUIDString], extension]];
    [self.restClient loadFile:self.path intoPath:destinationPath];
}

-(void) cancel {
    [self.restClient cancelFileLoad:self.path];
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath contentType:(NSString *)contentType metadata:(DBMetadata *)metadata {
    UIImage *image = [UIImage imageWithContentsOfFile:localPath];
    self.completedBlock(image, nil);
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    self.completedBlock(nil, error);
}

- (void)restClient:(DBRestClient*)client loadProgress:(CGFloat)progress forFile:(NSString*)destPath {
    if (self.progressBlock)
        self.progressBlock(progress);
}

@end


@interface DropboxThumbnailLoad : DropboxImageLoad

@property(nonatomic, readonly) NSString *size;

-(id) initWithPath:(NSString *)path size:(NSString *)size completed:(OnlineImageInfoCompletedBlock)completedBlock;

@end

@implementation DropboxThumbnailLoad

-(id) initWithPath:(NSString *)path size:(NSString *)size completed:(OnlineImageInfoCompletedBlock)completedBlock {
    if (self = [super initWithPath:path progress:nil completed:completedBlock])
        _size = size;
    return self;
}

-(void) startLoad {
    NSString *destinationPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", [[NSUUID UUID] UUIDString]]];
    [self.restClient loadThumbnail:self.path ofSize:self.size intoPath:destinationPath];
}

-(void) cancel {
    [self.restClient cancelThumbnailLoad:self.path size:self.size];
}

- (void)restClient:(DBRestClient*)client loadedThumbnail:(NSString*)localPath metadata:(DBMetadata*)metadata {
    UIImage *image = [UIImage imageWithContentsOfFile:localPath];
    self.completedBlock(image, nil);
}

- (void)restClient:(DBRestClient*)client loadThumbnailFailedWithError:(NSError*)error {
    self.completedBlock(nil, error);
}

@end


@implementation DropboxImageInfo

-(id) initWithMetadata:(DBMetadata *)metadata {
    if (self = [super init]) {
        self.dbMetadata = metadata;
    }
    return self;
}

-(id<OnlineImageLoad>) loadThumbnailForTargetSize:(CGSize)size
                                         progress:(OnlineImageInfoProgressBlock)progressBlock
                                        completed:(OnlineImageInfoCompletedBlock)completedBlock {
    NSString *sizeString = [self sizeStringFor:size];
    return [[DropboxThumbnailLoad alloc] initWithPath:self.dbMetadata.path size:sizeString completed:completedBlock];
}

-(NSString *) sizeStringFor:(CGSize)size {
    CGFloat width = MAX(size.width, size.height);
    if (width >= 700)
        return @"xl";
    else if (width >= 200)
        return @"l";
    else if (width >= 80)
        return @"m";
    else if (width >= 40)
        return @"s";
    return @"xs";
}

-(id<OnlineImageLoad>) loadFullSizeWithProgress:(OnlineImageInfoProgressBlock)progressBlock
                                      completed:(OnlineImageInfoCompletedBlock)completedBlock {
    return [[DropboxImageLoad alloc] initWithPath:self.dbMetadata.path progress:progressBlock completed:completedBlock];
}

-(id) metadata {
    return self.dbMetadata;
}

@end
