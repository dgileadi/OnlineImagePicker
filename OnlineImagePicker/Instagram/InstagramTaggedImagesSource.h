//
//  InstagramTaggedImagesSource.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnlineImageSource.h"

/**
 * Provides images from Instagram with a given tag.
 */
@interface InstagramTaggedImagesSource : NSObject <OnlineImageSource>

/** The tag (without a # symbol) to load images for. */
@property(nonatomic) NSString *tag;

/** Initialize with a tag. */
-(id) initWithTag:(NSString *)tag;

@end
