//
//  PhotoLibraryImageInfo.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/19/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __IPHONE_8_0
#import <Photos/Photos.h>
#endif
#import "OnlineImageInfo.h"

@interface PhotoLibraryImageInfo : NSObject<OnlineImageInfo>
#if __IPHONE_8_0

@property(nonatomic) PHAsset *asset;

-(id) initWithAsset:(PHAsset *)asset;

#endif
@end
