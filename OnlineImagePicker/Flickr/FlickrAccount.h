//
//  FlickrAccount.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/6/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnlineImageAccount.h"

/**
 * Supports user authentication for Flickr.
 */
@interface FlickrAccount : NSObject<OnlineImageAccount>

/** The single shared instance of this class. */
+(FlickrAccount *) sharedInstance;

/** Register this application with FlickrKit. In most cases this will be called automatically but it doesn't hurt to call it yourself. */
-(void) registerWithFlickrKit;

@end
