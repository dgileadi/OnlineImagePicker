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
@property(nonatomic) NSDate *lastRequest;
@property(nonatomic) NSUInteger requested;

@end

@implementation OnlineImageManager

-(id) init {
    if (self = [super init]) {
        self.sources = [NSMutableArray array];
        self.accounts = [NSMutableArray array];
        self.pageSize = 64;
        self.nextQueryTimeout = 5;
        self.requeryTimeout = 15;
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
    _accounts = nil;
}

-(void) addImageSourcesFromArray:(NSArray *)sources {
    [self.sources addObjectsFromArray:sources];
    _accounts = nil;
}

-(void) removeImageSource:(id<OnlineImageSource>)source {
    [self.sources removeObject:source];
    _accounts = nil;
}

-(void) removeAllImageSources {
    [self.sources removeAllObjects];
}

-(NSArray *) accounts {
    if (!_accounts) {
        [self setAccounts:[NSMutableArray array]];
        for (id<OnlineImageSource> source in self.sources) {
            id<OnlineImageAccount> account = [source account];
            if (account) {
                BOOL found = NO;
                for (id<OnlineImageAccount> existing in _accounts)
                    if (account == existing || [[account class] isSubclassOfClass:[existing class]] || [[existing class] isSubclassOfClass:[account class]]) {
                        found = YES;
                        break;
                    }
                if (!found)
                    [_accounts addObject:account];
            }
        }
    }
    return _accounts;
}

-(void) setPageSize:(NSUInteger)pageSize {
    _pageSize = pageSize;
    [self updateSourcesPageSize];
}

-(void) updateSourcesPageSize {
    NSUInteger availableCount = 0;
    for (id<OnlineImageSource> source in self.sources) {
        if ([source isAvailable])
            availableCount++;
    }
    if (availableCount) {
        NSUInteger pageSize = round(((double) self.pageSize) / availableCount);
        for (id<OnlineImageSource> source in self.sources)
            source.pageSize = pageSize;
    }
}

-(BOOL) hasMoreImages {
    for (id<OnlineImageSource> source in self.sources)
        if (source.isAvailable && source.hasMoreImages)
            return YES;
    return NO;
}

-(BOOL) isLoading {
    for (id<OnlineImageSource> source in self.sources)
        if (source.isAvailable && source.isLoading)
            return YES;
    return NO;
}

-(void) loadImagesWithSuccess:(OnlineImageResultsBlock)onSuccess orFailure:(OnlineImageFailureBlock)onFailure {
    [self updateSourcesPageSize];
    self.requested = 0;
    for (id<OnlineImageSource> source in self.sources)
        if (source.isAvailable)
            [source loadImages:^(NSArray *results, NSError *error) {
                if (!error)
                    onSuccess(results, source);
                else
                    onFailure(error, source);
            }];
}

-(void) nextImagesWithSuccess:(OnlineImageResultsBlock)onSuccess orFailure:(OnlineImageFailureBlock)onFailure {
    [self updateSourcesPageSize];
    self.requested += self.pageSize;
    
    NSTimeInterval loadWait = 0;
    BOOL anyLoading = NO;
    for (id<OnlineImageSource> source in self.sources)
        if (source.isAvailable && source.isLoading) {
            anyLoading = YES;
            loadWait = MAX(loadWait, -source.loadStartTime.timeIntervalSinceNow);
        }
    
    for (id<OnlineImageSource> source in self.sources)
        // query if available and:
        //  1) the source isn't currently loading and either no other source is loading or we're past the next query timeout
        //  2) the source is currently loading but has passed its requery timeout
        if (source.isAvailable && ((!source.isLoading && (!anyLoading || loadWait > self.nextQueryTimeout)) || -source.loadStartTime.timeIntervalSinceNow > self.requeryTimeout))
            [source nextImages:^(NSArray *results, NSError  *error) {
                if (!error)
                    onSuccess(results, source);
                else
                    onFailure(error, source);
            }];
}

@end
