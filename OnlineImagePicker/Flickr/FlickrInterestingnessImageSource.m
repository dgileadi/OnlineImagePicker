//
//  FlickrInterestingnessImageSource.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/7/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "FlickrInterestingnessImageSource.h"

@implementation FlickrInterestingnessImageSource

-(BOOL) isAvailable {
    return YES;
}

-(id<OnlineImageAccount>) account {
    return nil;
}

-(NSString *) call {
    return @"flickr.interestingness.getList";
}

-(NSDictionary *) argsWithCount:(NSUInteger)count {
    return @{@"per_page": [NSString stringWithFormat:@"%d", count],
             @"page": [NSString stringWithFormat:@"%d", self.page]};
}

@end
