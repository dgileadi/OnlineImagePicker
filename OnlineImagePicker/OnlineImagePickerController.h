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
#import "OnlineImageAccountsController.h"


/**
 * A delegate that handles images being picked.
 */
@protocol OnlineImagePickerDelegate <NSObject>

-(void) imagePickedWithInfo:(id<OnlineImageInfo>)info andThumbnail:(UIImage *)thumbnail;
-(void) cancelledPicker;

@end


/**
 * An implementation of UICollectionViewController that supports loading images from online sources like Facebook, Instagram and Flickr.
 * You must set `pickerDelegate` to get notified when images are picked.
 */
@interface OnlineImagePickerController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIToolbarDelegate, OnlineImageAccountsDelegate>

/**
 * A delegate for handling picked images. You must set the delegate to get notified of picked images.
 */
@property(weak, nonatomic) id<OnlineImagePickerDelegate> pickerDelegate;

/**
 * A toolbar for displaying Cancel and Accounts buttons.
 */
@property(nonatomic) IBOutlet UIToolbar *toolbar;

/**
 * Whether to load high-resolution image on retina displays. Defaults to NO, meaning thumbnail images will generally be loaded at non-retina resolution.
 * Also note that not all image sources support high-resolution thumbnails.
 */
@property(nonatomic) BOOL highResThumbnails;

/**
 * The preferred size for thumbnail images. The exact size will be adjusted based on the view's size. Defaults to 70x70.
 */
@property(nonatomic) CGSize preferredThumbnailSize;

/**
 * The margin between cells. Defaults to 2x2.
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
