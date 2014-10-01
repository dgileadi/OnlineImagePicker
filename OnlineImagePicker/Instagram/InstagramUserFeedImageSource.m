//
//  InstagramUserFeedImageSource.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "InstagramUserFeedImageSource.h"
#import <InstagramKit/InstagramKit.h>
#import "InstagramImageInfo.h"
#import "InstagramAccount.h"

@interface InstagramUserFeedImageSource()
@property(nonatomic) InstagramPaginationInfo *pagination;
@end

@implementation InstagramUserFeedImageSource

@synthesize pageSize;

/** This image source is only available if a user has been authenticated to Instagram. */
-(BOOL) isAvailable {
    return [InstagramEngine sharedEngine].accessToken != nil;
}

-(id<OnlineImageAccount>) account {
    return [InstagramAccount sharedInstance];
}

-(BOOL) hasMoreImages {
    return self.pagination.nextMaxId != nil;
}

-(void) loadImagesWithSuccess:(OnlineImageSourceResultsBlock)onSuccess orFailure:(OnlineImageSourceFailureBlock)onFailure {
    self.pagination = nil;
    [self nextImagesWithSuccess:onSuccess orFailure:onFailure];
}

-(void) nextImagesWithSuccess:(OnlineImageSourceResultsBlock)onSuccess orFailure:(OnlineImageSourceFailureBlock)onFailure {
    [[InstagramEngine sharedEngine] getSelfFeedWithCount:self.pageSize maxId:self.pagination.nextMaxId success:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
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
