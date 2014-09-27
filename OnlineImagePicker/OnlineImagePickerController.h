//
//  OnlineImagePickerController.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/27/14.
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
 * You must set `pickerDelegate` to get notified when images are picked.
 */
@interface OnlineImagePickerController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate>

/**
 * A delegate for handling picked images. You must set the delegate to get notified of picked images.
 */
@property(weak, nonatomic) id<OnlineImagePickerDelegate> pickerDelegate;

/**
 * Whether to load low-resolution image on retina displays. Defaults to NO, meaning thumbnail images will be loaded at retina resolution when possible.
 */
@property(nonatomic) BOOL lowResThumbnails;

/**
 * The preferred size for thumbnail images. The exact size will be adjusted based on the view's size.
 */
@property(nonatomic) CGSize preferredThumbnailSize;

/**
 * The margin between cells.
 */
@property(nonatomic) CGSize cellMargins;

/**
 * The OnlineImageManager that loads images from OnlineImageSource objects.
 */
@property(nonatomic) OnlineImageManager *imageManager;

/**
 * Initialize with a delegate.
 */
-(id) initWithDelegate:(id<OnlineImagePickerDelegate>)delegate;

/**
 * Initialize with a delegate and objects that implement the OnlineImageSource protocol.
 */
-(id) initWithDelegate:(id<OnlineImagePickerDelegate>)delegate andImageSources:(NSArray *)imageSources;

/**
 * Initialize with a delegate and an OnlineImageManager.
 */
-(id) initWithDelegate:(id<OnlineImagePickerDelegate>)delegate andImageManager:(OnlineImageManager *)manager;

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
