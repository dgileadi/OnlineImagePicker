//
//  OnlineImagePicker.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/5/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "OnlineImagePicker.h"
#import "OnlineImagePickerCell.h"
#import "PhotoLibraryImageSource.h"
#import "InstagramUserImagesSource.h"
#import <SDWebImage/UIImageView+WebCache.h>


static NSString *identifier = @"OnlineImagePickerCell";


@interface OnlineImagePicker()

@property(nonatomic) NSMutableArray *imageInfo;

@end


@implementation OnlineImagePicker

/*
 SDWebImageDownloader *downloader = [SDWebImageManager sharedManager].imageDownloader;
 downloader.headersFilter = ^NSDictionary *(NSURL *url, NSDictionary *headers) {
 };
 */


/**
 * Initialize the picker with a default set of image sources, including the photo library and user images from popular online services.
 */
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.imageManager = [[OnlineImageManager alloc] init];
        self.imageInfo = [NSMutableArray array];
        [self addDefaultImageSources];
    }
    return self;
}

-(id) initWithImageManager:(OnlineImageManager *)manager {
    if (self = [super init]) {
        self.imageManager = manager;
        self.imageInfo = [NSMutableArray array];
    }
    return self;
}

/**
 * Initialize the picker with a default set of image sources, including the photo library and user images from popular online services.
 */
-(id) init {
    if (self = [self initWithImageManager:[[OnlineImageManager alloc] init]]) {
        [self addDefaultImageSources];
    }
    return self;
}

-(id) initWithImageSources:(NSArray *)imageSources {
    if (self = [self initWithImageManager:[[OnlineImageManager alloc] init]])
        [self addImageSourcesFromArray:imageSources];
    return self;
}

-(void) addDefaultImageSources {
    [self addImageSource:[[PhotoLibraryImageSource alloc] init]];
    [self addImageSource:[[InstagramUserImagesSource alloc] init]];
    // TODO: Facebook, Flickr, Dropbox user images
}

-(NSArray *)imageSources {
    return self.imageManager.imageSources;
}

-(void) addImageSource:(id<OnlineImageSource>)source {
    [self.imageManager addImageSource:source];
}

-(void) addImageSourcesFromArray:(NSArray *)sources {
    [self.imageManager addImageSourcesFromArray:sources];
}

-(void) removeImageSource:(id<OnlineImageSource>)source {
    [self.imageManager removeImageSource:source];
}

-(void) removeAllImageSources {
    [self.imageManager removeAllImageSources];
}

-(void) loadImages {
    [self.imageManager loadImagesWithSuccess:^(NSArray *results, id<OnlineImageSource> source) {
        for (id<OnlineImageInfo> info in results)
            [self.imageInfo addObject:info];
// TODO: maybe sort
        [self.collectionView reloadData];
    } orFailure:^(NSError *error, id<OnlineImageSource> source) {
        
// TODO: what?
        
        
        NSLog(@"Error from %@: %@", source, error);
    }];
}

#pragma mark - UICollectionView

-(void) viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[OnlineImagePickerCell class] forCellWithReuseIdentifier:identifier];
    [self loadImages];
}

#pragma mark - UICollectionViewDataSource

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageInfo.count;
}

#pragma mark - UICollectionViewDelegate

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OnlineImagePickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    id<OnlineImageInfo> imageInfo = [self.imageInfo objectAtIndex:indexPath.item];
    cell.imageInfo = imageInfo;
    
    [cell.imageView sd_cancelCurrentImageLoad];
    
    CGSize size = cell.bounds.size;
    if (!self.lowResThumbnails) {
        CGFloat scale = self.view.window.screen.scale;
        if (scale > 1)
            size = CGSizeMake(size.width * scale, size.height * scale);
    }
    
    __weak OnlineImagePickerCell *wcell = cell;
    [imageInfo loadThumbnailForTargetSize:size completed:^(UIImage *image, NSError *error) {
        if (!wcell)
            return;
        dispatch_main_sync_safe(^{
            if (image) {
                wcell.imageView.image = image;
                [wcell.imageView setNeedsLayout];
            }
            if (error) {
// TODO: what?
                
                
                NSLog(@"Error loading image: %@", error);
            }
        });
    }];
    
// TODO: maybe some kind of placeholder, support for progress, support for half-resolution image first...
    
    return cell;
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (self.pickerDelegate) {
        OnlineImagePickerCell *cell = (OnlineImagePickerCell *) [self.collectionView cellForItemAtIndexPath:indexPath];
        [self.pickerDelegate imagePickedWithInfo:cell.imageInfo andThumbnail:cell.imageView.image];
    }
}

@end
