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


@interface InstagramPopularImagesSource()
@property(nonatomic) NSDate *loadStarted;
@end


@implementation InstagramPopularImagesSource

-(BOOL) isAvailable {
    return YES;
}

-(id<OnlineImageAccount>) account {
    return nil;
}

-(BOOL) hasMoreImages {
    return NO;
}

-(BOOL) isLoading {
    return self.loadStarted != nil;
}

-(NSDate *) loadStartTime {
    return self.loadStarted;
}

-(void) load:(NSUInteger)count images:(OnlineImageSourceResultsBlock)resultsBlock {
    self.loadStarted = [NSDate date];
    [[InstagramEngine sharedEngine] getPopularMediaWithSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        self.loadStarted = nil;
        NSMutableArray *results = [NSMutableArray arrayWithCapacity:media.count];
        for (InstagramMedia *item in media)
            if (!item.isVideo)
                [results addObject:[[InstagramImageInfo alloc] initWithMedia:item]];
        resultsBlock(results, nil);
    } failure:^(NSError *error) {
        resultsBlock(nil, error);
    }];
}

-(void) next:(NSUInteger)count images:(OnlineImageSourceResultsBlock)resultsBlock {
    resultsBlock(nil, nil);
}

@end
