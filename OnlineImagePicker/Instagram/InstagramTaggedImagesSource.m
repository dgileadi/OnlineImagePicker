//
//  InstagramTaggedImagesSource.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "InstagramTaggedImagesSource.h"
#import <InstagramKit/InstagramKit.h>
#import "InstagramImageInfo.h"

@interface InstagramTaggedImagesSource()
@property(nonatomic) InstagramPaginationInfo *pagination;
@property(nonatomic) NSDate *loadStarted;
@end

@implementation InstagramTaggedImagesSource

@synthesize pageSize;

-(id) initWithTag:(NSString *)tag {
    if (self = [super init])
        self.tag = tag;
    return self;
}

-(BOOL) isAvailable {
    return YES;
}

-(id<OnlineImageAccount>) account {
    return nil;
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
    [[InstagramEngine sharedEngine] getMediaWithTagName:self.tag count:self.pageSize maxId:self.pagination.nextMaxId withSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        self.loadStarted = nil;
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
