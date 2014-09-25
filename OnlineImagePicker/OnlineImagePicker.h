//
//  OnlineImagePicker.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/5/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OnlineImageSource.h"
#import "OnlineImageManager.h"
#import "OnlineImageInfo.h"


/**
 * A delegate that handles images being picked.
 */
@protocol OnlineImagePickerDelegate <NSObject>

-(void) imagePickedWithInfo:(id<OnlineImageInfo>)info andThumbnail:(UIImage *)thumbnail;

@end


/**
 * An implementation of UICollectionViewController that supports loading images from online sources like Facebook, Instagram and Flickr.
 */
@interface OnlineImagePicker : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property(weak, nonatomic) id<OnlineImagePickerDelegate> pickerDelegate;

/**
 * Whether to load low-resolution image on retina displays. Defaults to NO, meaning thumbnail images will be loaded at retina resolution when possible.
 */
@property(nonatomic) BOOL lowResThumbnails;

/**
 * The OnlineImageManager that loads images from OnlineImageSource objects.
 */
@property(nonatomic) OnlineImageManager *imageManager;

/**
 * Initialize with objects that implement the OnlineImageSource protocol
 */
-(id) initWithImageSources:(NSArray *)imageSources;

/**
 * Initialize with an OnlineImageManager.
 */
-(id) initWithImageManager:(OnlineImageManager *)manager;

/**
 * All the OnlineImageSource objects that provide images for this picker. Forwards to imageManager.
 */
-(NSArray *)imageSources;

/**
 * Add an object that implements the OnlineImageSource protocol, which will be queried for images if active. Forwards to imageManager.
 */
-(void) addImageSource:(id<OnlineImageSource>)source;

/**
 * Add objects that implement the OnlineImageSource protocol from an array.
 */
-(void) addImageSourcesFromArray:(NSArray *)sources;

/**
 * Remove an object from imageSources. Forwards to imageManager.
 */
-(void) removeImageSource:(id<OnlineImageSource>)source;

/**
 * Remove all objects from imageSources. Forwards to imageManager.
 */
-(void) removeAllImageSources;

@end
