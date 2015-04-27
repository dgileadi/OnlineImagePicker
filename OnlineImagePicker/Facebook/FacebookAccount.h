//
//  FacebookAccount.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnlineImageAccount.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>

/**
 * Supports user authentication for Facebook.
 */
@interface FacebookAccount : NSObject<OnlineImageAccount>

/** The single shared instance of this class. */
+(FacebookAccount *) sharedInstance;

@end
