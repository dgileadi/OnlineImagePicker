//
//  FacebookMyUploadedImagesSource.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "FacebookMyUploadedImagesSource.h"

@implementation FacebookMyUploadedImagesSource

-(NSString *) graphURL {
    return @"/me/photos/uploaded";
}

@end
