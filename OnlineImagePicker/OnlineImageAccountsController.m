//
//  OnlineImageAccountsController.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/27/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "OnlineImageAccountsController.h"


static NSString * const kCellIdentifier = @"OnlineImageAccountCell";


@interface OnlineImageAccountsController ()

@property(nonatomic, weak) id<OnlineImageAccountsDelegate> delegate;

@end


@interface OnlineImageAccountsTableController : UITableViewController

@property(nonatomic, weak) id<OnlineImageAccountsDelegate> delegate;
@property(nonatomic) NSArray *accounts;

-(id) initWithDelegate:(id<OnlineImageAccountsDelegate>)delegate;

@end


@implementation OnlineImageAccountsController

-(id) initWithDelegate:(id<OnlineImageAccountsDelegate>)delegate {
    OnlineImageAccountsTableController *tableController = [[OnlineImageAccountsTableController alloc] initWithDelegate:delegate];
    if (self = [super initWithRootViewController:tableController]) {
        self.delegate = delegate;
        [self setAccounts:delegate.accounts];
    }
    return self;
}

-(void) setAccounts:(NSArray *)accounts {
    accounts = [accounts sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 description] compare:[obj2 description]];
    }];
    ((OnlineImageAccountsTableController *) [self.viewControllers objectAtIndex:0]).accounts = accounts;
}

@end


@implementation OnlineImageAccountsTableController

-(id) initWithDelegate:(id<OnlineImageAccountsDelegate>)delegate {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [[self bundle] localizedStringForKey:@"AccountsTitle" value:@"Online Accounts" table:nil];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneManagingAccounts)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

// sometimes login doesn't notify us so reload when we appear
-(void) viewDidAppear:(BOOL)animated {
    [self.tableView reloadData];
}

-(void) doneManagingAccounts {
    [self.delegate doneManagingAccounts];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellIdentifier];

    id<OnlineImageAccount> account = [self.accounts objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [account description];
    
    NSBundle *bundle = [self bundle];
    NSString *login = [bundle localizedStringForKey:@"AccountLogin" value:@"Sign In" table:nil];
    NSString *logout = [bundle localizedStringForKey:@"AccountLogout" value:@"Sign Out" table:nil];
    cell.detailTextLabel.text = [account isLoggedIn] ? logout : login;
    
    UIImage *icon = [account icon];
    if (![account isLoggedIn])
        icon = [self convertImageToGrayScale:icon];
    cell.imageView.image = icon;
    
    cell.accessoryType = [account isLoggedIn] ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(NSBundle *) bundle {
    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"OnlineImagePicker" ofType:@"bundle"]];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id<OnlineImageAccount> account = [self.accounts objectAtIndex:indexPath.row];
    if ([account isLoggedIn]) {
        [account logout];
        [self.tableView reloadData];
    } else {
        [account loginFromController:self.navigationController thenCall:^(NSError *error, id<OnlineImageAccount> account) {
            [self.tableView reloadData];
        }];
    }
}

/*
 * From http://iosdevelopertips.com/graphics/convert-an-image-uiimage-to-grayscale.html
 */
-(UIImage *) convertImageToGrayScale:(UIImage *)image {
    CGSize size = image.size;
    if (image.scale > 1)
        size = CGSizeApplyAffineTransform(size, CGAffineTransformMakeScale(image.scale, image.scale));
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, size.width, size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef grayImage = CGBitmapContextCreateImage(context);
    
    // release the colorspace and graphics context
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    // make a new alpha-only graphics context
    context = CGBitmapContextCreate(nil, size.width, size.height, 8, 0, nil, kCGImageAlphaOnly);
    
    // draw image into context with no colorspace
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // create alpha bitmap mask from current context
    CGImageRef mask = CGBitmapContextCreateImage(context);
    
    // release graphics context
    CGContextRelease(context);
    
    // make UIImage from grayscale image with alpha mask
    UIImage *grayScaleImage = [UIImage imageWithCGImage:CGImageCreateWithMask(grayImage, mask) scale:image.scale orientation:image.imageOrientation];
    
    // release the CG images
    CGImageRelease(grayImage);
    CGImageRelease(mask);
    
    // return the new grayscale image
    return grayScaleImage;
}

@end
