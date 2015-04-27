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
#import <FBSDKCoreKit/FBSDKCoreKit.h>


@interface FacebookImageSource()

@property(nonatomic) NSString *after;
@property(nonatomic) BOOL nextRequested;
@property(nonatomic) NSDate *loadStarted;

@end


@implementation FacebookImageSource

/** This image source is only available if we have a username to load images for. */
-(BOOL) isAvailable {
    return [FacebookAccount sharedInstance].isLoggedIn;
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

-(void) load:(NSUInteger)count images:(OnlineImageSourceResultsBlock)resultsBlock {
    self.after = nil;
    self.nextRequested = NO;
    [self next:count images:resultsBlock];
}

-(void) next:(NSUInteger)count images:(OnlineImageSourceResultsBlock)resultsBlock {
    self.loadStarted = [NSDate date];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%lu", (unsigned long) count], @"limit", @"id,images,created_time,updated_time", @"fields", nil];
    if (self.after) {
        parameters[@"after"] = self.after;
        self.nextRequested = YES;
    }
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"user_photos"]) {
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:[self graphURL] parameters:parameters];
        FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
        [connection addRequest:request completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
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
        [connection start];
    }
}

@end
