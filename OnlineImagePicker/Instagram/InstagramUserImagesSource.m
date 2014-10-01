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
@end

@implementation InstagramUserImagesSource

@synthesize pageSize;

/** This image source is only available if we have a username to load images for. */
-(BOOL) isAvailable {
    return self.username != nil || [InstagramEngine sharedEngine].accessToken != nil;
}

-(id<OnlineImageAccount>) account {
    return [InstagramAccount sharedInstance];
}

-(BOOL) hasMoreImages {
    return self.pagination.nextMaxId != nil;
}

-(void) loadImagesWithSuccess:(OnlineImageSourceResultsBlock)onSuccess orFailure:(OnlineImageSourceFailureBlock)onFailure {
    self.pagination = nil;
    if (!self.username) {
        [[InstagramEngine sharedEngine] getSelfUserDetailsWithSuccess:^(InstagramUser *userDetail) {
            self.username = userDetail.username;
            [self nextImagesWithSuccess:onSuccess orFailure:onFailure];
        } failure:^(NSError *error) {
            NSLog(@"Error loading details for Instagram self user: %@", error);
        }];
    } else {
        [self nextImagesWithSuccess:onSuccess orFailure:onFailure];
    }
}

-(void) nextImagesWithSuccess:(OnlineImageSourceResultsBlock)onSuccess orFailure:(OnlineImageSourceFailureBlock)onFailure {
    [[InstagramEngine sharedEngine] getMediaForUser:self.username count:self.pageSize maxId:self.pagination.nextMaxId withSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        self.pagination = paginationInfo;
        NSMutableArray *results = [NSMutableArray arrayWithCapacity:media.count];
        for (InstagramMedia *item in media)
            if (!item.isVideo)
                [results addObject:[[InstagramImageInfo alloc] initWithMedia:item]];
        onSuccess(results);
    } failure:^(NSError *error) {
        onFailure(error);
    }];
}

@end
