//
//  FacebookImageInfo.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <InstagramKit/InstagramKit.h>
#import "SDWebImageInfo.h"

/**
 * Provides information about a Facebook image.
 */
@interface FacebookImageInfo : SDWebImageInfo

/** The same as the metadata property, returns information about the Facebook photo. */
@property(nonatomic) NSDictionary* photoData;

/**
 * Create an instance with the given Facebook photo data.
 *
 * @param data May not be nil.
 */
-(id) initWithData:(NSDictionary *)data;

@end
