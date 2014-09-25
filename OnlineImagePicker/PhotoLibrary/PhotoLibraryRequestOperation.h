//
//  PhotoLibraryRequestOperation.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/25/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#if __IPHONE_8_0

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "OnlineImageInfo.h"

@interface PhotoLibraryRequestOperation : NSObject <OnlineImageLoad>

/**
 * The ID of the request used by the operation.
 */
@property (nonatomic, readonly) PHImageRequestID requestID;

/**
 *  Initializes a `PhotoLibraryRequestOperation` object
 *
 *  @param requestID The ID of the request.
 *
 *  @return the initialized instance
 */
- (id)initWithRequestID:(PHImageRequestID)requestID;

@end

#endif