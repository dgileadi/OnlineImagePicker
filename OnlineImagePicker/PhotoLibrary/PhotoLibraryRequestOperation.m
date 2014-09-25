//
//  PhotoLibraryRequestOperation.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/25/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "PhotoLibraryRequestOperation.h"

@implementation PhotoLibraryRequestOperation
#if __IPHONE_8_0

- (id)initWithRequestID:(PHImageRequestID)requestID {
    if ((self = [super init])) {
        _requestID = requestID;
    }
    return self;
}

- (void)cancel {
    [[PHImageManager defaultManager] cancelImageRequest:self.requestID];
}

#endif
@end
