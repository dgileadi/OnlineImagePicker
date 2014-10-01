//
//  InstagramImageInfo.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/19/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "OnlineImageInfo.h"
#import <Foundation/Foundation.h>
#import <InstagramKit/InstagramKit.h>
#import "SDWebImageInfo.h"

/**
 * Provides information about an Instagram image.
 */
@interface InstagramImageInfo : SDWebImageInfo

/** The same as the metadata property, returns information about the Instagram media. */
@property(nonatomic) InstagramMedia* instagramMedia;

/**
 * Create an instance with the given Instagram media.
 *
 * @param media May not be nil.
 */
-(id) initWithMedia:(InstagramMedia *)media;

@end
