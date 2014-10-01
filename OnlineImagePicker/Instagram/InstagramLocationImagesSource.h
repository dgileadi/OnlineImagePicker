//
//  InstagramLocationImagesSource.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "OnlineImageSource.h"

/**
 * Provides images from Instagram near a given location.
 */
@interface InstagramLocationImagesSource : NSObject <OnlineImageSource>

/** The location to load images near. */
@property(nonatomic) CLLocationCoordinate2D location;

/** Initialize with a location. */
-(id) initWithLocation:(CLLocationCoordinate2D)location;

@end
