//
//  InstagramUserImagesSource.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/8/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnlineImageSource.h"

/**
 * Provides user images from Instagram. Requires that a user be authenticated unless `userId` is populated by hand.
 */
@interface InstagramUserImagesSource : NSObject <OnlineImageSource>

/** The username to get images for. If none is provided it defaults to the logged-in user. */
@property(nonatomic) NSString *username;

@end
