//
//  FacebookImageSource.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "FacebookImageSource.h"
#import "FacebookAccount.h"
#import "FacebookImageInfo.h"
#import "OnlineImageAccount.h"
#import <FacebookSDK/FacebookSDK.h>


@interface FacebookImageSource()

@property(nonatomic) NSString *after;
@property(nonatomic) BOOL nextRequested;
@property(nonatomic) NSDate *loadStarted;

@end


@implementation FacebookImageSource

@synthesize pageSize;

/** This image source is only available if we have a username to load images for. */
-(BOOL) isAvailable {
    return [[FacebookAccount sharedInstance] isLoggedIn];
}

-(id<OnlineImageAccount>) account {
    return [FacebookAccount sharedInstance];
}

-(BOOL) hasMoreImages {
    return !self.nextRequested || self.after != nil;
}

-(NSString *) graphURL {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(BOOL) isLoading {
    return self.loadStarted != nil;
}

-(NSDate *) loadStartTime {
    return self.loadStarted;
}

-(void) loadImages:(OnlineImageSourceResultsBlock)resultsBlock {
    self.after = nil;
    self.nextRequested = NO;
    [self nextImages:resultsBlock];
}

-(void) nextImages:(OnlineImageSourceResultsBlock)resultsBlock {
    self.loadStarted = [NSDate date];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%lu", (unsigned long) self.pageSize], @"limit", @"id,images,created_time,updated_time", @"fields", nil];
    if (self.after) {
        parameters[@"after"] = self.after;
        self.nextRequested = YES;
    }
    [FBRequestConnection startWithGraphPath:[self graphURL] parameters:parameters HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        self.loadStarted = nil;
        NSMutableArray *results = nil;
        if (!error) {
            NSDictionary *paging = [result objectForKey:@"paging"];
            self.after = [paging objectForKey:@"after"];
            
            NSArray *data = [result objectForKey:@"data"];
            NSMutableArray *results = [NSMutableArray arrayWithCapacity:data.count];
            for (NSDictionary *photo in data)
                [results addObject:[[FacebookImageInfo alloc] initWithData:photo]];
        } else {
            NSLog(@"An error occurred getting images from Facebook: %@", [error localizedDescription]);
        }
        
        resultsBlock(results, error);
    }];
}

@end
