//
//  DropboxImagesSource.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "DropboxImagesSource.h"


@interface DropboxImagesSource()

@property(nonatomic) DBRestClient *restClient;

@end


@implementation DropboxImagesSource

-(id) init {
    if (self = [super init]) {
        self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        self.restClient.delegate = self;
    }
    return self;
}

@synthesize pageSize;

/** This image source is only available if we the user has logged into Dropbox. */
-(BOOL) isAvailable {
    return [[self account] isLoggedIn];
}

-(id<OnlineImageAccount>) account {
    return [DropboxAccount sharedInstance];
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

#pragma mark - DBRestClientDelegate

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory) {
        NSLog(@"Folder '%@' contains:", metadata.path);
        for (DBMetadata *file in metadata.contents) {
            NSLog(@"	%@", file.filename);
        }
    }
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    NSLog(@"Error loading metadata: %@", error);
}

@end
