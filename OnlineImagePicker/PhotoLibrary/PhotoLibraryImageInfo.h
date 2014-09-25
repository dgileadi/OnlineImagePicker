//
//  PhotoLibraryImageInfo.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/19/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#if __IPHONE_8_0

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "OnlineImageInfo.h"

@interface PhotoLibraryImageInfo : NSObject<OnlineImageInfo>

@property(nonatomic) PHAsset *asset;

-(id) initWithAsset:(PHAsset *)asset;

@end

#endif