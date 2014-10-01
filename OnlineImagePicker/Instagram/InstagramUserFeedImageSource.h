//
//  InstagramUserFeedImageSource.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnlineImageSource.h"

/**
 * Provides images from the Instagram user's feed. Requires that a user be authenticated.
 */
@interface InstagramUserFeedImageSource : NSObject<OnlineImageSource>

@end
