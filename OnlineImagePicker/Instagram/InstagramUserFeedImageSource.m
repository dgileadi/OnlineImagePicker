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
@property(nonatomic) NSDate *loadStarted;
@end

@implementation InstagramUserFeedImageSource

/** This image source is only available if a user has been authenticated to Instagram. */
-(BOOL) isAvailable {
    return [InstagramEngine sharedEngine].accessToken != nil;
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
    [self next:count images:resultsBlock];
}

-(void) next:(NSUInteger)count images:(OnlineImageSourceResultsBlock)resultsBlock {
    self.loadStarted = [NSDate date];
    [[InstagramEngine sharedEngine] getSelfFeedWithCount:count maxId:self.pagination.nextMaxId success:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
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
