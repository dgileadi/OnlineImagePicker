//
//  FlickrUserImagesSource.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/6/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "FlickrUserImagesSource.h"
#import <FlickrKit/FlickrKit.h>
#import "FlickrAccount.h"

@implementation FlickrUserImagesSource

/** This image source is only available if we have a username to load images for or if the current user is logged in. */
-(BOOL) isAvailable {
    return !self.username || ![self.username isEqualToString:@"me"] || [FlickrKit sharedFlickrKit].authorized;
}

-(id<OnlineImageAccount>) account {
    return [FlickrAccount sharedInstance];
}

-(NSString *) call {
    return [FlickrKit sharedFlickrKit].authorized ? @"flickr.people.getPhotos" : @"flickr.people.getPublicPhotos";
}

-(NSDictionary *) args {
    return @{@"user_id": self.username,
             @"per_page": [NSString stringWithFormat:@"%d", self.pageSize],
             @"page": [NSString stringWithFormat:@"%d", self.page]};
}

-(void) load:(NSUInteger)count images:(OnlineImageSourceResultsBlock)resultsBlock {
    if (!self.username)
        self.username = @"me";
    if ([self.username isEqualToString:@"me"] && ![FlickrKit sharedFlickrKit].authorized)
        [[FlickrKit sharedFlickrKit] checkAuthorizationOnCompletion:^(NSString *userName, NSString *userId, NSString *fullName, NSError *error) {
            if (error)
                resultsBlock(nil, error);
            else
                [super load:count images:resultsBlock];
        }];
    else
        [super load:count images:resultsBlock];
}

@end
