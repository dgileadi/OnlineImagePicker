//
//  DropboxImagesSource.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK.h>
#import "OnlineImageSource.h"

/**
 * Provides images that the user uploaded to Dropbox. Requires that the user be authenticated.
 */
@interface DropboxImagesSource : NSObject <OnlineImageSource, DBRestClientDelegate>

/** The path strings to search, in order. Defaults to "/Camera Uploads", "/Photos" and "/". */
@property(nonatomic) NSArray *paths;

/** Path to exclude. Defaults to "/Screenshots". */
@property(nonatomic) NSSet *excludePaths;

@end
