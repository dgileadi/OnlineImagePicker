//
//  DropboxImagesSource.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "DropboxImagesSource.h"
#import "DropboxImageInfo.h"
#import "DropboxAccount.h"


@interface DropboxImagesSource()

@property(nonatomic) DBRestClient *restClient;
@property(nonatomic) NSUInteger pathsIndex;
@property(nonatomic) NSMutableSet *crawled;
@property(nonatomic) NSMutableArray *uncrawled;
@property(nonatomic) NSUInteger uncrawledIndex;
@property(nonatomic) NSMutableArray *photos;
@property(nonatomic) NSUInteger index;
@property(nonatomic, strong) OnlineImageSourceResultsBlock resultsBlock;
@property(nonatomic) NSDate *loadStarted;

@end


@implementation DropboxImagesSource

-(id) init {
    if (self = [super init]) {
        self.paths = [NSArray arrayWithObjects:@"/Camera Uploads", @"Photos", @"/", nil];
        self.pathsIndex = 0;
        self.excludePaths = [NSSet setWithObject:@"/Screenshots"];
        self.crawled = [NSMutableSet set];
        self.uncrawled = [NSMutableArray array];
        self.uncrawledIndex = 0;
        self.photos = [NSMutableArray array];
        self.index = 0;
    }
    return self;
}

@synthesize pageSize;

-(DBRestClient *) restClient {
    if (!_restClient && [DBSession sharedSession]) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    return _restClient;
}

/** This image source is only available if we the user has logged into Dropbox. */
-(BOOL) isAvailable {
    return [[self account] isLoggedIn];
}

-(id<OnlineImageAccount>) account {
    return [DropboxAccount sharedInstance];
}

-(BOOL) hasMoreImages {
    return self.index != NSUIntegerMax;
}

-(BOOL) isLoading {
    return self.loadStarted != nil;
}

/** If isLoading returns YES, returns the time that the load started. */
-(NSDate *) loadStartTime {
    return self.loadStarted;
}

-(void) loadImages:(OnlineImageSourceResultsBlock)resultsBlock {
    self.index = 0;
    [self nextImages:resultsBlock];
}

-(void) nextImages:(OnlineImageSourceResultsBlock)resultsBlock {
    self.resultsBlock = resultsBlock;
    NSUInteger reported = 0;
    if (self.index < self.photos.count)
        reported = [self reportPhotos];
    
    if (reported < self.pageSize) {
        if (self.uncrawledIndex < self.uncrawled.count) {
            [self crawl:self.uncrawled[self.uncrawledIndex]];
            self.uncrawledIndex++;
        } else if (self.pathsIndex < self.paths.count) {
            [self crawl:self.paths[self.pathsIndex]];
            self.pathsIndex++;
        } else {
            self.index = NSUIntegerMax;
        }
    }
}

-(void) crawl:(NSString *)path {
    self.loadStarted = [NSDate date];
    [self.crawled addObject:path];
    [self.restClient loadMetadata:path];
}

-(NSUInteger) reportPhotos {
    self.loadStarted = nil;
    NSUInteger reported = 0;
    if (self.index < self.photos.count) {
        reported = MIN(self.pageSize, self.photos.count - self.index);
        NSMutableArray *results = [NSMutableArray arrayWithCapacity:reported];
        for (NSUInteger i = 0; i < reported; i++) {
            [results addObject:[[DropboxImageInfo alloc] initWithMetadata:self.photos[self.index]]];
            self.index++;
        }
        self.resultsBlock(results, nil);
    }
    return reported;
}

#pragma mark - DBRestClientDelegate

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory) {
        NSMutableArray *photos = [NSMutableArray array];
        for (DBMetadata *file in metadata.contents) {
            if (file.thumbnailExists)
                [photos addObject:file];
            else if (file.isDirectory && ![self.crawled containsObject:file.path])
                [self.uncrawled addObject:file.path];
        }
        
        if (photos.count) {
            [photos sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                DBMetadata *m1 = obj1;
                DBMetadata *m2 = obj2;
                return [m2.clientMtime compare:m1.clientMtime];
            }];
            [self.photos addObjectsFromArray:photos];
            [self reportPhotos];
        }
    }
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    self.loadStarted = nil;
    self.resultsBlock(nil, error);
}

@end
