//
//  PhotoLibraryRequestOperation.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/25/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#if __IPHONE_8_0

#import "PhotoLibraryRequestOperation.h"

@implementation PhotoLibraryRequestOperation

- (id)initWithRequestID:(PHImageRequestID)requestID {
    if ((self = [super init])) {
        _requestID = requestID;
    }
    return self;
}

- (void)cancel {
    [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
}

@end

#endif