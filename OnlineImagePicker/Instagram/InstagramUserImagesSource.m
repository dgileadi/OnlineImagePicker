//
//  InstagramUserImagesSource.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/8/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "InstagramUserImagesSource.h"
#import <InstagramKit/InstagramKit.h>
#import "InstagramImageInfo.h"
#import "InstagramAccount.h"

@interface InstagramUserImagesSource()
@property(nonatomic) InstagramPaginationInfo *pagination;
@property(nonatomic) NSDate *loadStarted;
@end

@implementation InstagramUserImagesSource

/** This image source is only available if we have a username to load images for. */
-(BOOL) isAvailable {
    return self.username != nil || [InstagramEngine sharedEngine].accessToken != nil;
}

-(id<OnlineImageAccount>) account {
    return [InstagramAccount sharedInstance];
}

-(BOOL) hasMoreImages {
    return self.pagination == nil || self.pagination.nextMaxId != nil;
}

-(BOOL) isLoading {
    return self.loadStarted != nil;
}

-(NSDate *) loadStartTime {
    return self.loadStarted;
}

-(void) load:(NSUInteger)count images:(OnlineImageSourceResultsBlock)resultsBlock {
    self.pagination = nil;
    if (!self.username) {
        self.loadStarted = [NSDate date];
        [[InstagramEngine sharedEngine] getSelfUserDetailsWithSuccess:^(InstagramUser *userDetail) {
            self.username = userDetail.username;
            [self next:count images:resultsBlock];
        } failure:^(NSError *error) {
            NSLog(@"Error loading details for Instagram self user: %@", error);
        }];
    } else {
        [self next:count images:resultsBlock];
    }
}

-(void) next:(NSUInteger)count images:(OnlineImageSourceResultsBlock)resultsBlock {
    self.loadStarted = [NSDate date];
    [[InstagramEngine sharedEngine] getMediaForUser:self.username count:count maxId:self.pagination.nextMaxId withSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        self.loadStarted = nil;
        self.pagination = paginationInfo;
        NSMutableArray *results = [NSMutableArray arrayWithCapacity:media.count];
        for (InstagramMedia *item in media)
            if (!item.isVideo)
                [results addObject:[[InstagramImageInfo alloc] initWithMedia:item]];
        resultsBlock(results, nil);
    } failure:^(NSError *error) {
        self.loadStarted = nil;
        resultsBlock(nil, error);
    }];
}

@end
