//
//  InstagramSelfLikedImagesSource.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "InstagramSelfLikedImagesSource.h"
#import <InstagramKit/InstagramKit.h>
#import "InstagramImageInfo.h"
#import "InstagramAccount.h"

@interface InstagramSelfLikedImagesSource()
@property(nonatomic) InstagramPaginationInfo *pagination;
@property(nonatomic) NSDate *loadStarted;
@end

@implementation InstagramSelfLikedImagesSource

@synthesize pageSize;

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

-(void) loadImages:(OnlineImageSourceResultsBlock)resultsBlock {
    self.pagination = nil;
    [self nextImages:resultsBlock];
}

-(void) nextImages:(OnlineImageSourceResultsBlock)resultsBlock {
    self.loadStarted = [NSDate date];
    [[InstagramEngine sharedEngine] getMediaLikedBySelfWithCount:self.pageSize maxId:self.pagination.nextMaxId success:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
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
