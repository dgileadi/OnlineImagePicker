//
//  OnlineImageManager.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/10/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "OnlineImageManager.h"


@interface OnlineImageManager()

@property(nonatomic) NSMutableArray *sources;
@property(nonatomic) NSMutableArray *accounts;
@property(nonatomic) NSUInteger sourcePageSize;
@property(nonatomic) NSUInteger requestedToSelf;
@property(nonatomic) NSUInteger requestedFromSources;
@property(nonatomic) NSUInteger receivedFromSources;
@property(nonatomic) BOOL inLoadCall;

@end


@implementation OnlineImageManager

-(id) init {
    if (self = [super init]) {
        self.sources = [NSMutableArray array];
        self.accounts = [NSMutableArray array];
        self.pageSize = 64;
        self.nextQueryTimeout = 3;
        self.requeryTimeout = 10;
        self.requestedToSelf = 0;
        self.requestedFromSources = 0;
        self.receivedFromSources = 0;
        self.inLoadCall = NO;
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
    self.sourcePageSize = [self calcSourcePageSizeFrom:self.pageSize includeMoreImages:NO];
}

-(NSUInteger) calcSourcePageSizeFrom:(NSUInteger)pageSize includeMoreImages:(BOOL)includeMoreImages {
    NSUInteger availableCount = 0;
    for (id<OnlineImageSource> source in self.sources) {
        if (source.isAvailable && (!includeMoreImages || source.hasMoreImages))
            availableCount++;
    }
    if (availableCount)
        return round(((double) pageSize) / availableCount);
    else
        return 0;
}

-(BOOL) hasMoreImages {
    for (id<OnlineImageSource> source in self.sources)
        if (source.isAvailable && source.hasMoreImages)
            return YES;
    [self limitRequestedToSelf];
    return NO;
}

-(BOOL) isLoading {
    return self.requestedToSelf > self.receivedFromSources;
}

-(void) limitRequestedToSelf {
    // if there are no more images, make isLoading return NO
    self.requestedToSelf = self.receivedFromSources;
}

-(void) loadImagesWithSuccess:(OnlineImageResultsBlock)successBlock orFailure:(OnlineImageFailureBlock)failureBlock {
    self.sourcePageSize = [self calcSourcePageSizeFrom:self.pageSize includeMoreImages:NO];
    self.requestedToSelf = self.pageSize;
    self.requestedFromSources = 0;
    self.receivedFromSources = 0;
    self.inLoadCall = YES;
    for (id<OnlineImageSource> source in self.sources) {
        // query if available and has more images and:
        //  1) the source isn't currently loading and either no other source is loading or we're past the next query timeout
        //  2) the source is currently loading but has passed its requery timeout
        if (source.isAvailable)
            self.requestedFromSources += self.sourcePageSize;
            [source load:self.sourcePageSize images:^(NSArray *results, NSError  *error) {
                [self handleResults:results andError:error fromSource:source expectedCount:self.sourcePageSize withSuccess:successBlock orFailure:failureBlock];
            }];
    }
    
    [self asyncAfter:self.nextQueryTimeout next:self.sourcePageSize imagesFromAllSources:YES withSuccess:successBlock orFailure:failureBlock];
    
    self.inLoadCall = NO;
}

-(void) nextImagesWithSuccess:(OnlineImageResultsBlock)successBlock orFailure:(OnlineImageFailureBlock)failureBlock {
    self.sourcePageSize = [self calcSourcePageSizeFrom:self.pageSize includeMoreImages:YES]; // in case one or more sources became unavailable or exhausted
    if (!self.sourcePageSize) {
        [self limitRequestedToSelf];
        successBlock(nil, nil);
    } else {
        self.requestedToSelf += self.pageSize;
        self.inLoadCall = NO;
        [self next:self.sourcePageSize imagesFromAllSources:YES withSuccess:successBlock orFailure:failureBlock];
    }
}

-(void) next:(NSUInteger)sourceCount imagesFromAllSources:(BOOL)allSources withSuccess:(OnlineImageResultsBlock)successBlock orFailure:(OnlineImageFailureBlock)failureBlock {
    // prevent recursion, which can happen when sources call their blocks synchronously
    if (self.inLoadCall) {
        [self asyncAfter:0 next:sourceCount imagesFromAllSources:allSources withSuccess:successBlock orFailure:failureBlock];
        return;
    }
    self.inLoadCall = YES;
    
    NSTimeInterval loadWait = 0;
    BOOL anyLoading = NO;
    for (id<OnlineImageSource> source in self.sources)
        if (source.isAvailable && source.isLoading) {
            anyLoading = YES;
            loadWait = MAX(loadWait, -source.loadStartTime.timeIntervalSinceNow);
        }
    
    for (id<OnlineImageSource> source in self.sources)
        // query if available and has more images and:
        //  1) the source isn't currently loading and either no other source is loading or we're past the next query timeout
        //  2) the source is currently loading but has passed its requery timeout
        if (source.isAvailable && source.hasMoreImages && ((!source.isLoading && (!anyLoading || loadWait > self.nextQueryTimeout)) || -source.loadStartTime.timeIntervalSinceNow > self.requeryTimeout)) {
            self.requestedFromSources += sourceCount;
            [source next:sourceCount images:^(NSArray *results, NSError  *error) {
                [self handleResults:results andError:error fromSource:source expectedCount:sourceCount withSuccess:successBlock orFailure:failureBlock];
            }];
            
            if (!allSources)
                break;
        }
    
    if (allSources && self.requestedToSelf > self.receivedFromSources)
        [self asyncAfter:self.nextQueryTimeout - loadWait next:sourceCount imagesFromAllSources:allSources withSuccess:successBlock orFailure:failureBlock];
    
    self.inLoadCall = NO;
}

-(void) asyncAfter:(NSTimeInterval)wait next:(NSUInteger)sourceCount imagesFromAllSources:(BOOL)allSources withSuccess:(OnlineImageResultsBlock)successBlock orFailure:(OnlineImageFailureBlock)failureBlock {
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, MAX(0, wait) * NSEC_PER_SEC);
    dispatch_after(when, dispatch_get_main_queue(), ^(void){
        [self next:sourceCount imagesFromAllSources:allSources withSuccess:successBlock orFailure:failureBlock];
    });
}

-(void) handleResults:(NSArray *)results andError:(NSError *)error fromSource:(id<OnlineImageSource>)source expectedCount:(NSUInteger)sourceCount withSuccess:(OnlineImageResultsBlock)successBlock orFailure:(OnlineImageFailureBlock)failureBlock {
    self.receivedFromSources += results.count;
    if (error)
        failureBlock(error, source);
    if (results.count)
        successBlock(results, source);
    
    if (results.count < sourceCount && self.requestedToSelf > self.receivedFromSources) {
        // if we didn't get enough images from this source, fill from another source
        self.sourcePageSize = [self calcSourcePageSizeFrom:self.pageSize includeMoreImages:YES]; // in case one or more sources became unavailable or exhausted
        [self next:sourceCount - results.count imagesFromAllSources:NO withSuccess:successBlock orFailure:failureBlock];
    } else if (self.requestedToSelf > self.requestedFromSources) {
        // or if we need an entirely new page of results, ask for it
        NSUInteger count = [self calcSourcePageSizeFrom:self.requestedToSelf - self.requestedFromSources includeMoreImages:YES];
        [self next:count imagesFromAllSources:YES withSuccess:successBlock orFailure:failureBlock];
    }
}

@end
