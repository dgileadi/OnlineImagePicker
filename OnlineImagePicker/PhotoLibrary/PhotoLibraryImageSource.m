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

@end


@implementation PhotoLibraryImageSource

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
                if ([group numberOfAssets] > 0)
                    [self.assetsGroups addObject:group];
            } failureBlock:^(NSError *error) {
                self.error = error;
            }];
        }
        self.index = 0;
        self.error = nil;
    }
    return self;
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

-(BOOL) hasMoreImages {
    if (self.assetsLibrary)
        return self.index != NSUIntegerMax;
    else
#if __IPHONE_8_0
        return self.index < self.assets.count;
#else
    return YES;
#endif
}

-(BOOL) isLoading {
    return NO;
}

-(NSDate *) loadStartTime {
    return nil;
}

-(void) load:(NSUInteger)count images:(OnlineImageSourceResultsBlock)resultsBlock {
    self.index = 0;
    return [self next:count images:resultsBlock];
}

-(void) next:(NSUInteger)count images:(OnlineImageSourceResultsBlock)resultsBlock {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
#if __IPHONE_8_0
        if (self.index >= self.assets.count) {
            resultsBlock(nil, nil);
            return;
        } else if (self.index + count > self.assets.count)
            count = self.assets.count - self.index;
        
        __block NSMutableArray *results = [NSMutableArray arrayWithCapacity:count];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.index, count)];
        [self.assets enumerateObjectsAtIndexes:indexSet options:0 usingBlock:^(id asset, NSUInteger idx, BOOL *stop) {
            [results addObject:[[PhotoLibraryImageInfo alloc] initWithAsset:asset]];
        }];
        
        resultsBlock(results, nil);
        
        self.index += count;
#endif
    } else {
        if (self.error) {
            resultsBlock(nil, self.error);
            if (!self.assetsGroups.count)
                return;
        }
        if (self.index == NSUIntegerMax) {
            resultsBlock(nil, nil);
            return;
        }
        
        NSUInteger groupPageSize = count;
        if (self.assetsGroups.count > 1)
            groupPageSize = MAX(1, count / self.assetsGroups.count);
        
        BOOL requested = NO;
        for (ALAssetsGroup *group in self.assetsGroups) {
            if (self.index >= group.numberOfAssets)
                continue;
            
            requested = YES;
            ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
            [group setAssetsFilter:onlyPhotosFilter];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.index, MIN(groupPageSize, group.numberOfAssets - self.index))];
            [group enumerateAssetsAtIndexes:indexSet options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result)
                    resultsBlock([NSArray arrayWithObject:result], nil);
            }];
        }
        
        if (!requested) {
            resultsBlock(nil, nil);
            self.index = NSUIntegerMax;
        } else
            self.index += groupPageSize;
    }
}

@end
