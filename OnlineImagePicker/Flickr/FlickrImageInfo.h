//
//  FlickrImageInfo.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/6/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebImageInfo.h"

/**
 * Provides information about a Facebook image.
 */
@interface FlickrImageInfo : SDWebImageInfo

/** The same as the metadata property, returns information about the Flickr photo. */
@property(nonatomic) NSDictionary* photoData;

/**
 * Create an instance with the given Flickr photo data.
 *
 * @param data May not be nil.
 */
-(id) initWithData:(NSDictionary *)data;

@end
