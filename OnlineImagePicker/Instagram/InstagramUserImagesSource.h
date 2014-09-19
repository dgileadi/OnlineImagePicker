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
 * Provides user images from Instagram. Requires that a user be authenticated.
 */
@interface InstagramUserImagesSource : NSObject <OnlineImageSource>

@end
