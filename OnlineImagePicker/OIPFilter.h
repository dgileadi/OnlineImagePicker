//
//  OIPFilter.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/5/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>

// some terms & conditions prevent loading more than 30 images at a time, so we limit the count to that
#define MAX_COUNT 30

@interface OIPFilter : NSObject

@property(nonatomic) NSUInteger first;
@property(nonatomic) NSUInteger count;

@end
