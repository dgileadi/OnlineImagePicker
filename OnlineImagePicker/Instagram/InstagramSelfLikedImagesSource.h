//
//  InstagramSelfLikedImagesSource.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnlineImageSource.h"

/**
 * Provides images that the logged-in Instagram user liked. Requires that a user be authenticated.
 */
@interface InstagramSelfLikedImagesSource : NSObject <OnlineImageSource>

@end
