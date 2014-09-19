//
//  ALAssetImageInfo.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/19/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "OnlineImageInfo.h"

@interface ALAssetImageInfo : NSObject<OnlineImageInfo>

@property(nonatomic) ALAsset *asset;

-(id) initWithAsset:(ALAsset *)asset;

@end
