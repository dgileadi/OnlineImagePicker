//
//  FlickrUserImagesSource.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/6/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "FlickrUserImagesSource.h"
#import <FlickrKit/FlickrKit.h>
#import "FlickrImageInfo.h"
#import "FlickrAccount.h"

@interface FlickrUserImagesSource()
@property(nonatomic) NSUInteger pages;
@property(nonatomic) NSUInteger page;
@property(nonatomic) NSDate *loadStarted;
@end

@implementation FlickrUserImagesSource

-(id) init {
    if (self = [super init]) {
        self.pages = NSUIntegerMax;
        self.page = 0;
        self.username = @"me";
        [[FlickrAccount sharedInstance] registerWithFlickrKit];
    }
    return self;
}

/** This image source is only available if we have a username to load images for. */
-(BOOL) isAvailable {
    return (self.username != nil && ![self.username isEqualToString:@"me"]) || [FlickrKit sharedFlickrKit].authorized;
}

-(id<OnlineImageAccount>) account {
    return [FlickrAccount sharedInstance];
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

-(void) next:(NSUInteger)count images:(OnlineImageSourceResultsBlock)resultsBlock {
    self.loadStarted = [NSDate date];
    self.page++;
    NSString *call = [FlickrKit sharedFlickrKit].authorized ? @"flickr.people.getPhotos" : @"flickr.people.getPublicPhotos";
    NSDictionary *args = @{@"user_id": self.username,
                           @"per_page": [NSString stringWithFormat:@"%d", count],
                           @"page": [NSString stringWithFormat:@"%d", self.page]};
    [[FlickrKit sharedFlickrKit] call:call args:args maxCacheAge:FKDUMaxAgeFiveMinutes completion:^(NSDictionary *response, NSError *error) {
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
