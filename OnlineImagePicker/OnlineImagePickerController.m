//
//  OnlineImagePickerController.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/5/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "OnlineImagePickerController.h"
#import "OnlineImagePickerCell.h"
#import "PhotoLibraryImageSource.h"
#import "InstagramUserImagesSource.h"
#import "InstagramPopularImagesSource.h"
#import <SDWebImage/UIImageView+WebCache.h>


static NSString * const kCellIdentifier = @"OnlineImagePickerCell";


@interface OnlineImagePickerController()

@property(nonatomic) NSMutableArray *imageInfo;

@end


@implementation OnlineImagePickerController

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
        [self initDefaults];
        [self addDefaultImageSources];
    }
    return self;
}

-(id) initWithDelegate:(id<OnlineImagePickerDelegate>)delegate {
    
    if (self = [self initWithDelegate:delegate andImageManager:[[OnlineImageManager alloc] init]]) {
        [self addDefaultImageSources];
    }
    return self;
}

-(id) initWithDelegate:(id<OnlineImagePickerDelegate>)delegate andImageManager:(OnlineImageManager *)manager {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    if (self = [super initWithCollectionViewLayout:layout]) {
        self.pickerDelegate = delegate;
        self.imageManager = manager;
        [self initDefaults];
    }
    return self;
}

/**
 * Initialize the picker with a default set of image sources, including the photo library and user images from popular online services.
 */
-(id) init {
    return [self initWithDelegate:nil];
}

-(id) initWithDelegate:(id<OnlineImagePickerDelegate>)delegate andImageSources:(NSArray *)imageSources {
    if (self = [self initWithDelegate:delegate andImageManager:[[OnlineImageManager alloc] init]])
        [self addImageSourcesFromArray:imageSources];
    return self;
}

-(void) initDefaults {
    self.imageInfo = [NSMutableArray array];
    self.preferredContentSize = CGSizeMake(75, 75);
    self.cellMargins = CGSizeMake(2, 2);
}

-(void) addDefaultImageSources {
    [self addImageSource:[[PhotoLibraryImageSource alloc] init]];
    [self addImageSource:[[InstagramUserImagesSource alloc] init]];
    [self addImageSource:[[InstagramPopularImagesSource alloc] init]];
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

-(void) updateCellLayout {
    CGFloat width = self.view.bounds.size.width;
    NSUInteger count = width / self.preferredContentSize.width;
    CGFloat margins = self.cellMargins.width * (count - 1);
    CGFloat cellWidth = (width - margins) / count;
    CGFloat cellHeight = self.preferredContentSize.height;
    if (ABS(self.preferredContentSize.width - self.preferredContentSize.height) < 0.1)
        cellHeight = cellWidth;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(cellWidth, cellHeight);
    layout.minimumInteritemSpacing = self.cellMargins.width;
    layout.minimumLineSpacing = self.cellMargins.height;
    layout.sectionInset = UIEdgeInsetsZero;
    self.collectionView.collectionViewLayout = layout;
    
    self.imageManager.pageSize = count * ceil(self.view.bounds.size.height / cellHeight);
}

-(void) createToolbar {
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    toolbar.delegate = self;
    
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"OnlineImagePicker" ofType:@"bundle"]];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPicker)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSString *title = [bundle localizedStringForKey:@"AccountsBarButton" value:@"Accounts" table:nil];
    UIBarButtonItem *accounts = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(showSelectAccounts)];
    toolbar.items = [NSArray arrayWithObjects:cancel, space, accounts, nil];
    
    self.toolbar = toolbar;
    [self.view addSubview:toolbar];
    
    id topGuide = self.topLayoutGuide;
    NSDictionary *views = NSDictionaryOfVariableBindings(topGuide, toolbar);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[toolbar]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-[toolbar]" options:0 metrics:nil views:views]];
}

-(void) showSelectAccounts {
// TODO
}

-(void) cancelPicker {
    [self.pickerDelegate cancelledPicker];
}

#pragma mark - UICollectionView

-(void) viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[OnlineImagePickerCell class] forCellWithReuseIdentifier:kCellIdentifier];
    [self updateCellLayout];
    if (!self.toolbar)
        [self createToolbar];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self loadImages];
}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.collectionView.contentInset = UIEdgeInsetsMake(self.toolbar.bounds.size.height + [self.topLayoutGuide length], 0, 0, 0);
}

#if __IPHONE_8_0
-(void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self updateCellLayout];
}
#else
-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    [self updateCellLayout];
}
#endif

#pragma mark - UICollectionViewDataSource

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageInfo.count;
}

#pragma mark - UICollectionViewDelegate

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OnlineImagePickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    id<OnlineImageInfo> imageInfo = [self.imageInfo objectAtIndex:indexPath.item];
    cell.imageInfo = imageInfo;
    
    CGFloat scale = self.highResThumbnails ? self.view.window.screen.scale : 1;
    [cell loadImageAtScale:scale];
    
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

#pragma mark - UIToolbarDelegate

-(UIBarPosition) positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
