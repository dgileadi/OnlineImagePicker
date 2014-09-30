//
//  PhotoLibraryImageSource.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/19/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "PhotoLibraryImageSource.h"
#import "ALAssetImageInfo.h"
#if __IPHONE_8_0
#import "PhotoLibraryImageInfo.h"
#endif

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@interface PhotoLibraryImageSource()

@property(nonatomic) NSUInteger index;
#if __IPHONE_8_0
@property(nonatomic) PHFetchResult *assets;
#endif
@property(nonatomic) ALAssetsLibrary *assetsLibrary;
@property(nonatomic) NSMutableArray *assetsGroups;
@property(nonatomic) NSError *error;
@property(nonatomic) NSUInteger groupPageSize;

@end


@implementation PhotoLibraryImageSource

@synthesize pageSize;

-(id) init {
    if (self = [super init]) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
#if __IPHONE_8_0
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            self.assets = [PHAsset fetchAssetsWithOptions:options];
#endif
        } else {
            self.assetsLibrary = [[ALAssetsLibrary alloc] init];
            self.assetsGroups = [NSMutableArray array];
            [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if ([group numberOfAssets] > 0) {
                    [self.assetsGroups addObject:group];
                    [self updateGroupPageSize];
                }
            } failureBlock:^(NSError *error) {
                self.error = error;
            }];
        }
        self.index = 0;
        self.error = nil;
    }
    return self;
}

-(void) setPageSize:(NSUInteger)size {
    pageSize = size;
    [self updateGroupPageSize];
}

-(void) updateGroupPageSize {
    if (self.assetsGroups.count)
        self.groupPageSize = MAX(1, self.pageSize / self.assetsGroups.count);
    else
        self.groupPageSize = 1;
}

-(BOOL) isAvailable {
    if (self.assetsLibrary)
        return self.error == nil || self.assetsGroups.count > 0;
    else
#if __IPHONE_8_0
        return PHPhotoLibrary.authorizationStatus == PHAuthorizationStatusAuthorized;
#else
        return YES;
#endif
}

-(id<OnlineImageAccount>) account {
    return nil;
}

-(void) loadImagesWithSuccess:(OnlineImageSourceResultsBlock)onSuccess orFailure:(OnlineImageSourceFailureBlock)onFailure {
    self.index = 0;
    return [self nextImagesWithSuccess:onSuccess orFailure:onFailure];
}

-(void) nextImagesWithSuccess:(OnlineImageSourceResultsBlock)onSuccess orFailure:(OnlineImageSourceFailureBlock)onFailure {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
#if __IPHONE_8_0
        if (self.index >= self.assets.count) {
            onSuccess([NSArray array]);
            return;
        }
        
        __block NSMutableArray *results = [NSMutableArray arrayWithCapacity:self.pageSize];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.index, self.pageSize)];
        [self.assets enumerateObjectsAtIndexes:indexSet options:0 usingBlock:^(id asset, NSUInteger idx, BOOL *stop) {
            [results addObject:[[PhotoLibraryImageInfo alloc] initWithAsset:asset]];
        }];
        
        onSuccess(results);
        
        self.index += self.pageSize;
#endif
    } else {
        if (self.error) {
            onFailure(self.error);
            if (!self.assetsGroups.count)
                return;
        }
        if (self.index == NSUIntegerMax) {
            onSuccess([NSArray array]);
            return;
        }
        
        BOOL requested = NO;
        for (ALAssetsGroup *group in self.assetsGroups) {
            if (self.index >= group.numberOfAssets)
                continue;
            
            requested = YES;
            ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
            [group setAssetsFilter:onlyPhotosFilter];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.index, MIN(self.pageSize, group.numberOfAssets - self.index))];
            [group enumerateAssetsAtIndexes:indexSet options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result)
                    onSuccess([NSArray arrayWithObject:result]);
            }];
        }
        
        if (!requested) {
            onSuccess([NSArray array]);
            self.index = NSUIntegerMax;
        } else
            self.index += self.groupPageSize;
    }
}

@end
