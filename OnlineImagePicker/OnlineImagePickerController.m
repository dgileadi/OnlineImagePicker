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
#import "DropboxImagesSource.h"
#import "InstagramUserImagesSource.h"
#import "FacebookMyUploadedImagesSource.h"
#import "FacebookImagesOfMeSource.h"
#import "FlickrUserImagesSource.h"
#import <SDWebImage/UIImageView+WebCache.h>


static NSString * const kCellIdentifier = @"OnlineImagePickerCell";


@interface OnlineImagePickerController()

@property(nonatomic) NSMutableArray *imageInfo;
@property(nonatomic) NSTimer *timer;

@end


@implementation OnlineImagePickerController

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
    [self addImageSource:[[DropboxImagesSource alloc] init]];
    [self addImageSource:[[FacebookMyUploadedImagesSource alloc] init]];
    [self addImageSource:[[FacebookImagesOfMeSource alloc] init]];
    [self addImageSource:[[FlickrUserImagesSource alloc] init]];
    [self addImageSource:[[InstagramUserImagesSource alloc] init]];
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
    if (self.imageManager.isLoading)
        return;
    
    __weak OnlineImagePickerController *wself = self;
    OnlineImageResultsBlock resultsBlock = ^(NSArray *results, id<OnlineImageSource> source) {
        if (!wself)
            return;
        
        // if we have a spinner, reload it
        BOOL spinnerCell = [wself.collectionView numberOfItemsInSection:0] > wself.imageInfo.count;
        
        // insert index paths
        NSUInteger count = results.count;
        if (count && spinnerCell && !wself.imageManager.isLoading)
            count--;
        else if (!spinnerCell && wself.imageManager.isLoading)
            count++;
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:count];
        for (NSUInteger i = 0; i < count; i++)
            [indexPaths addObject:[NSIndexPath indexPathForItem:wself.imageInfo.count + i inSection:0]];
        
        [wself.imageInfo addObjectsFromArray:results];
        
NSLog(@"Got %d items, spinnerCell: %d, loading: %d", results.count, spinnerCell, wself.imageManager.isLoading);
        
        [wself.collectionView insertItemsAtIndexPaths:indexPaths];
        if (spinnerCell)
            [wself.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:wself.imageInfo.count - results.count inSection:0]]];
    };
    OnlineImageFailureBlock failureBlock = ^(NSError *error, id<OnlineImageSource> source) {
        
        // TODO: what?
        
        
        NSLog(@"Error from %@: %@", source, error);
    };
    
    if (!self.imageInfo.count) {
        [self.imageManager loadImagesWithSuccess:resultsBlock orFailure:failureBlock];
        [self.collectionView reloadData];
    } else if (self.imageManager.hasMoreImages)
        [self.imageManager nextImagesWithSuccess:resultsBlock orFailure:failureBlock];
}

-(void) createTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(loadAndReapImages) userInfo:nil repeats:YES];
}

-(void) loadAndReapImages {
    // TODO: check whether we need to reap timed-out images, do so
    
}

-(void) updateCellLayoutToSize:(CGSize)size {
    CGFloat width = size.width;
    NSUInteger count = MAX(1, width / self.preferredContentSize.width);
    CGFloat margins = self.cellMargins.width * (count - 1);
    NSUInteger cellWidth = (width - margins) / count;
    NSUInteger cellHeight = self.preferredContentSize.height;
    if (ABS(self.preferredContentSize.width - self.preferredContentSize.height) < 0.1)
        cellHeight = cellWidth;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(cellWidth, cellHeight);
    layout.minimumInteritemSpacing = self.cellMargins.width;
    layout.minimumLineSpacing = self.cellMargins.height;
    layout.sectionInset = UIEdgeInsetsZero;
    self.collectionView.collectionViewLayout = layout;
    
    // load two screens of images at a time
    self.imageManager.pageSize = count * ceil(self.view.bounds.size.height / cellHeight) * 2;
}

-(void) createToolbar {
    UIBarButtonItem *accounts = [[UIBarButtonItem alloc] initWithTitle:[self accountsButtonTitle] style:UIBarButtonItemStylePlain target:self action:@selector(showSelectAccounts)];
    NSArray *items = nil;
    if (self.navigationController) {
        self.navigationItem.rightBarButtonItem = accounts;
    } else if (self.presentingViewController) {
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.pickerDelegate action:@selector(cancelledImagePicker)];
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        items = @[cancel, space, accounts];
    } else if (!self.parentViewController) {
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        items = @[space, accounts];
    }
    
    if (items) {
        UIToolbar *toolbar = [[UIToolbar alloc] init];
        toolbar.translatesAutoresizingMaskIntoConstraints = NO;
        toolbar.delegate = self;
        toolbar.items = items;
        
        self.toolbar = toolbar;
        [self.view addSubview:toolbar];
        
        id topGuide = self.topLayoutGuide;
        NSDictionary *views = NSDictionaryOfVariableBindings(topGuide, toolbar);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[toolbar]|" options:0 metrics:nil views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-[toolbar]" options:0 metrics:nil views:views]];
    }
}

-(NSString *) accountsButtonTitle {
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"OnlineImagePicker" ofType:@"bundle"]];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSUInteger activeCount = 0;
    for (id<OnlineImageAccount> account in self.imageManager.accounts)
        if (account.isLoggedIn)
            activeCount++;
    NSString *active = [numberFormatter stringFromNumber:[NSNumber numberWithUnsignedInteger:activeCount]];
    NSString *total = [numberFormatter stringFromNumber:[NSNumber numberWithUnsignedInteger:self.imageManager.accounts.count]];
    
    NSString *titleFormat = [bundle localizedStringForKey:@"AccountsBarButton" value:@"Accounts (%@/%@)" table:nil];
    return [NSString stringWithFormat:titleFormat, active, total];
}

-(void) showSelectAccounts {
    OnlineImageAccountsController *accountsController = [[OnlineImageAccountsController alloc] initWithDelegate:self];
    [self presentViewController:accountsController animated:YES completion:nil];
}

#pragma mark - OnlineImageAccountsDelegate

-(NSArray *) accounts {
    return self.imageManager.accounts;
}

-(void) doneManagingAccounts {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIBarButtonItem *accountsButton = [self.toolbar.items lastObject];
    accountsButton.title = [self accountsButtonTitle];
    
    [self loadImages];
}

#pragma mark - UICollectionView

-(void) viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[OnlineImagePickerCell class] forCellWithReuseIdentifier:kCellIdentifier];
    [self updateCellLayoutToSize:self.view.bounds.size];
    if (!self.timer)
        [self createTimer];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self loadImages];
}

-(void) viewWillAppear:(BOOL)animated {
    if (!self.toolbar)
        [self createToolbar];
}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.collectionView.contentInset = UIEdgeInsetsMake(self.toolbar.bounds.size.height + [self.topLayoutGuide length], 0, 0, 0);
}

#if __IPHONE_8_0
-(void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self updateCellLayoutToSize:size];
}
#else
-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    [self updateCellLayoutToSize:self.view.bounds.size];
}
#endif

-(void) didMoveToParentViewController:(UIViewController *)parent {
    if (!parent)
        [self.pickerDelegate cancelledImagePicker];
}

#pragma mark - UICollectionViewDataSource

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.imageManager.isLoading) {
NSLog(@"Loading, so count is %d", self.imageInfo.count + 1);
        return self.imageInfo.count + 1;
    }
NSLog(@"Not loading, so count is %d", self.imageInfo.count);
    return self.imageInfo.count;
}

#pragma mark - UICollectionViewDelegate

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OnlineImagePickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.scale = self.highResThumbnails ? self.view.window.screen.scale : 1;
    
    if (indexPath.item < self.imageInfo.count) {
        id<OnlineImageInfo> imageInfo = [self.imageInfo objectAtIndex:indexPath.item];
        cell.imageInfo = imageInfo;
// TODO: maybe some kind of placeholder
    } else {
        cell.imageInfo = nil;
    }
    
    return cell;
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (self.pickerDelegate) {
        OnlineImagePickerCell *cell = (OnlineImagePickerCell *) [self.collectionView cellForItemAtIndexPath:indexPath];
        if (cell.imageInfo)
            [self.pickerDelegate imagePickedWithInfo:cell.imageInfo andThumbnail:cell.imageView.image];
    }
}

#pragma mark - UIScrollViewDelegate

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat contentHeight = scrollView.contentSize.height;
    // TODO: sooner?
    if (offsetY > contentHeight - scrollView.frame.size.height)
        [self loadImages];
}

#pragma mark - UIToolbarDelegate

-(UIBarPosition) positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
