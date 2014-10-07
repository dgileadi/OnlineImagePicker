//
//  FlickrImagesSource.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/7/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "FlickrImagesSource.h"
#import <FlickrKit/FlickrKit.h>
#import "FlickrImageInfo.h"
#import "FlickrAccount.h"

@implementation FlickrImagesSource

-(id) init {
    if (self = [super init]) {
        self.pages = NSUIntegerMax;
        self.page = 0;
        [[FlickrAccount sharedInstance] registerWithFlickrKit];
    }
    return self;
}

-(BOOL) hasMoreImages {
    return self.pages == NSUIntegerMax || self.page < self.pages;
}

-(BOOL) isLoading {
    return self.loadStarted != nil;
}

-(NSDate *) loadStartTime {
    return self.loadStarted;
}

-(void) load:(NSUInteger)count images:(OnlineImageSourceResultsBlock)resultsBlock {
    self.page = 0;
    self.pages = NSUIntegerMax;
    [self next:count images:resultsBlock];
}

-(NSString *) call {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(NSDictionary *) argsWithCount:(NSUInteger)count {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(void) next:(NSUInteger)count images:(OnlineImageSourceResultsBlock)resultsBlock {
    self.loadStarted = [NSDate date];
    self.page++;
    [[FlickrKit sharedFlickrKit] call:[self call] args:[self argsWithCount:count] maxCacheAge:FKDUMaxAgeFiveMinutes completion:^(NSDictionary *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loadStarted = nil;
            NSMutableArray *results = nil;
            if (response) {
                if (self.pages == NSUIntegerMax)
                    self.pages = [[response valueForKeyPath:@"total"] unsignedIntegerValue];
                
                results = [NSMutableArray arrayWithCapacity:count];
                for (NSDictionary *photoDictionary in [response valueForKeyPath:@"photos.photo"])
                    [results addObject:[[FlickrImageInfo alloc] initWithData:photoDictionary]];
            }
            resultsBlock(results, error);
        });
    }];
}

@end
