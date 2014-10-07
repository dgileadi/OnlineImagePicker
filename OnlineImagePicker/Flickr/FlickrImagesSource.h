//
//  FlickrImagesSource.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/7/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnlineImageSource.h"

/** A base class for Flickr image sources. */
@interface FlickrImagesSource : NSObject

/** The number of pages of images available. Initialized to NSUIntegerMax, meaning unknown. */
@property(nonatomic) NSUInteger pages;

/** The current page among the pages, one-based. Initialized to zero. */
@property(nonatomic) NSUInteger page;

/** The date that the current load started. `nil` if no load is in progress. */
@property(nonatomic) NSDate *loadStarted;

/** *Subclasses must override:* return the API call to Flickr, such as @"flickr.people.getPublicPhotos". */
-(NSDictionary *) argsWithCount:(NSUInteger)count;

/** *Subclasses must override:* return arguments for the call to Flickr. */
-(NSDictionary *) argsWithCount:(NSUInteger)count;

@end
