//
//  OnlineImageManager.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/10/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "OnlineImageManager.h"
#import <InstagramKit/InstagramKit.h>

@implementation OnlineImageManager

-(NSArray *) images {
    [InstagramEngine sharedEngine];
}

@end
