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
@interface FlickrImagesSource : NSObject <OnlineImageSource>

/** The number of pages of images available. Initialized to NSUIntegerMax, meaning unknown. */
@property(nonatomic) NSUInteger pages;

/** The current page among the pages, one-based. Initialized to zero. */
@property(nonatomic) NSUInteger page;

/**
 * The page size. This source gathers the count during the call to `load:images:` and uses it for all calls to `next:images:`,
 * to avoid skipping/duplicating images while paging. Initialized to zero.
 */
@property(nonatomic) NSUInteger pageSize;

/** The date that the current load started. `nil` if no load is in progress. */
@property(nonatomic) NSDate *loadStarted;

/** *Subclasses must override:* the API call to Flickr, such as @"flickr.people.getPublicPhotos". */
-(NSString *) call;

/** *Subclasses must override:* arguments for the call to Flickr. */
-(NSDictionary *) args;

@end
