//
//  FacebookImageSource.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnlineImageSource.h"

/**
 * A base class for OnlineImageSource objects that get photos from Facebook.
 */
@interface FacebookImageSource : NSObject <OnlineImageSource>

/** The URL of the graph API to query. */
-(NSString *) graphURL;

@end
