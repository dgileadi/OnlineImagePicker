//
//  SDWebImageInfo.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/19/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnlineImageInfo.h"

@interface SDWebImageInfo : NSObject<OnlineImageInfo>

/** Subclasses must implement: return the URL for a thumbnail of the given target size. */
-(NSURL *) thumbnailURLForTargetSize:(CGSize) size;

/** Subclasses must implement: return the URL for the full-size image. */
-(NSURL *) fullSizeURL;

/** Subclasses must implement: return options for downloading the image. */
-(SDWebImageOptions) options;

@end
