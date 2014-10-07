//
//  FlickrUserImagesSource.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/6/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrImagesSource.h"

/**
 * Provides user images from Flickr. If `username` is not populated or the user is not logged in then only public photos will be displayed.
 */
@interface FlickrUserImagesSource : FlickrImagesSource

/** The username to get images for. If none is provided it defaults to the logged-in user. */
@property(nonatomic) NSString *username;

@end
