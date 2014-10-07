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

-(id) init {
    if (self = [super init]) {
        self.username = @"me";
    }
    return self;
}

/** This image source is only available if we have a username to load images for or if the current user is logged in. */
-(BOOL) isAvailable {
    return (self.username != nil && ![self.username isEqualToString:@"me"]) || [FlickrKit sharedFlickrKit].authorized;
}

-(id<OnlineImageAccount>) account {
    return [FlickrAccount sharedInstance];
}

-(NSString *) call {
    return [FlickrKit sharedFlickrKit].authorized ? @"flickr.people.getPhotos" : @"flickr.people.getPublicPhotos";
}

-(NSDictionary *) argsWithCount:(NSUInteger)count {
    return @{@"user_id": self.username,
             @"per_page": [NSString stringWithFormat:@"%d", count],
             @"page": [NSString stringWithFormat:@"%d", self.page]};
}

@end
