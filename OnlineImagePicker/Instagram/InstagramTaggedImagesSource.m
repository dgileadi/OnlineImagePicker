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
    return self.pagination.nextMaxId != nil;
}

-(void) loadImagesWithSuccess:(OnlineImageSourceResultsBlock)onSuccess orFailure:(OnlineImageSourceFailureBlock)onFailure {
    self.pagination = nil;
    [self nextImagesWithSuccess:onSuccess orFailure:onFailure];
}

-(void) nextImagesWithSuccess:(OnlineImageSourceResultsBlock)onSuccess orFailure:(OnlineImageSourceFailureBlock)onFailure {
    [[InstagramEngine sharedEngine] getMediaWithTagName:self.tag count:self.pageSize maxId:self.pagination.nextMaxId withSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
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
