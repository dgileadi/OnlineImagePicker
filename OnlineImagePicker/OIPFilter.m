//
//  OIPFilter.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/5/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "OIPFilter.h"

@implementation OIPFilter

-(void) setCount:(NSUInteger)count {
    return MIN(count, MAX_COUNT);
}

@end
