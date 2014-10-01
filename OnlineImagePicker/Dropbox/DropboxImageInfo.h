//
//  DropboxImageInfo.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "OnlineImageInfo.h"
#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>

/**
 * Provides information about a Dropbox image.
 */
@interface DropboxImageInfo : NSObject <OnlineImageInfo>

/** The same as the metadata property, returns information about the Dropbox item. */
@property(nonatomic) DBMetadata* dbMetadata;

/**
 * Create an instance with the given Dropbox metadata.
 *
 * @param metadata May not be nil.
 */
-(id) initWithMetadata:(DBMetadata *)metadata;

@end
