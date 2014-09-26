//
//  OnlineImageManager.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/10/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "OnlineImageManager.h"
#import <InstagramKit/InstagramKit.h>

@interface OnlineImageManager()

@property(nonatomic) NSMutableArray *sources;

@end

@implementation OnlineImageManager

-(id) init {
    if (self = [super init]) {
        self.sources = [NSMutableArray array];
        self.pageSize = 30;
    }
    return self;
}

-(id) initWithImageSources:(NSArray *)imageSources {
    if (self = [self init])
        [self.sources addObjectsFromArray:imageSources];
    return self;
}

-(NSArray *)imageSources {
    return self.sources;
}

-(void) addImageSource:(id<OnlineImageSource>)source {
    [self.sources addObject:source];
    [self updatePageSize];
}

-(void) addImageSourcesFromArray:(NSArray *)sources {
    [self.sources addObjectsFromArray:sources];
    [self updatePageSize];
}

-(void) removeImageSource:(id<OnlineImageSource>)source {
    [self.sources removeObject:source];
    [self updatePageSize];
}

-(void) removeAllImageSources {
    [self.sources removeAllObjects];
}

-(void) setPageSize:(NSUInteger)pageSize {
    _pageSize = pageSize;
    [self updatePageSize];
}

-(void) updatePageSize {
    NSUInteger availableCount = 0;
    for (id<OnlineImageSource> source in self.sources)
        if ([source isAvailable])
            availableCount++;
    NSUInteger pageSize = round(((double) self.pageSize) / availableCount);
    for (id<OnlineImageSource> source in self.sources)
        source.pageSize = pageSize;
}

-(void) loadImagesWithSuccess:(OnlineImageResultsBlock)onSuccess orFailure:(OnlineImageFailureBlock)onFailure {
    for (id<OnlineImageSource> source in self.sources)
        if (source.isAvailable)
            [source loadImagesWithSuccess:^(NSArray *results) {
                onSuccess(results, source);
            } orFailure:^(NSError *error) {
                onFailure(error, source);
            }];
}

-(void) nextImagesWithSuccess:(OnlineImageResultsBlock)onSuccess orFailure:(OnlineImageFailureBlock)onFailure {
    for (id<OnlineImageSource> source in self.sources)
        if (source.isAvailable)
            [source nextImagesWithSuccess:^(NSArray *results) {
                onSuccess(results, source);
            } orFailure:^(NSError *error) {
                onFailure(error, source);
            }];
}

@end
