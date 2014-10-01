//
//  InstagramPopularImagesSource.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/27/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "InstagramPopularImagesSource.h"
#import <InstagramKit/InstagramKit.h>
#import "InstagramImageInfo.h"

@implementation InstagramPopularImagesSource

@synthesize pageSize;

-(BOOL) isAvailable {
    return YES;
}

-(id<OnlineImageAccount>) account {
    return nil;
}

-(BOOL) hasMoreImages {
    return NO;
}

-(void) loadImagesWithSuccess:(OnlineImageSourceResultsBlock)onSuccess orFailure:(OnlineImageSourceFailureBlock)onFailure {
    [[InstagramEngine sharedEngine] getPopularMediaWithSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        NSMutableArray *results = [NSMutableArray arrayWithCapacity:media.count];
        for (InstagramMedia *item in media)
            if (!item.isVideo)
                [results addObject:[[InstagramImageInfo alloc] initWithMedia:item]];
        onSuccess(results);
    } failure:^(NSError *error) {
        onFailure(error);
    }];
}

-(void) nextImagesWithSuccess:(OnlineImageSourceResultsBlock)onSuccess orFailure:(OnlineImageSourceFailureBlock)onFailure {
    onSuccess(nil);
}

@end
