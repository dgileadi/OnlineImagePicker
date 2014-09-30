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
@property(nonatomic) NSMutableArray *accounts;

@end

@implementation OnlineImageManager

-(id) init {
    if (self = [super init]) {
        self.sources = [NSMutableArray array];
        self.accounts = [NSMutableArray array];
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
    [self updateImageSources];
}

-(void) addImageSourcesFromArray:(NSArray *)sources {
    [self.sources addObjectsFromArray:sources];
    [self updateImageSources];
}

-(void) removeImageSource:(id<OnlineImageSource>)source {
    [self.sources removeObject:source];
    [self updateImageSources];
}

-(void) removeAllImageSources {
    [self.sources removeAllObjects];
}

-(NSArray *) accounts {
    return self.accounts;
}

-(void) setPageSize:(NSUInteger)pageSize {
    _pageSize = pageSize;
    [self updateImageSources];
}

-(void) updateImageSources {
    NSUInteger availableCount = 0;
    [_accounts removeAllObjects];
    for (id<OnlineImageSource> source in self.sources) {
        if ([source isAvailable])
            availableCount++;
        id<OnlineImageAccount> account = [source account];
        if (account) {
            BOOL found = NO;
            for (id<OnlineImageAccount> existing in self.accounts)
                if ([[account class] isSubclassOfClass:[existing class]] || [[existing class] isSubclassOfClass:[account class]]) {
                    found = YES;
                    break;
                }
            if (!found)
                [_accounts addObject:account];
        }
    }
    if (availableCount) {
        NSUInteger pageSize = round(((double) self.pageSize) / availableCount);
        for (id<OnlineImageSource> source in self.sources)
            source.pageSize = pageSize;
    }
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
