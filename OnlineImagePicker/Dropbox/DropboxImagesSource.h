//
//  DropboxImagesSource.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>
#import "OnlineImageSource.h"

@interface DropboxImagesSource : NSObject <OnlineImageSource, DBRestClientDelegate>

@end
