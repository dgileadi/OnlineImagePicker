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

@end


@interface OnlineImageAccountsTableController : UITableViewController

@property(nonatomic) NSArray *accounts;

@end


@implementation OnlineImageAccountsController

-(id) init {
    OnlineImageAccountsTableController *tableController = [[OnlineImageAccountsTableController alloc] init];
    self = [super initWithRootViewController:tableController];
    return self;
}

@end


@implementation OnlineImageAccountsTableController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"OnlineImagePicker" ofType:@"bundle"]];
    NSString *login = [bundle localizedStringForKey:@"AccountLogin" value:@"Sign In" table:nil];
    NSString *logout = [bundle localizedStringForKey:@"AccountLogout" value:@"Sign Out" table:nil];
    cell.detailTextLabel.text = [account isLoggedIn] ? logout : login;
    
    UIImage *icon = [account icon];
    if (![account isLoggedIn])
        icon = [self convertImageToGrayScale:icon];
    cell.imageView.image = icon;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

/*
 * From http://iosdevelopertips.com/graphics/convert-an-image-uiimage-to-grayscale.html
 */
-(UIImage *) convertImageToGrayScale:(UIImage *)image {
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef grayImage = CGBitmapContextCreateImage(context);
    
    // release the colorspace and graphics context
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    // make a new alpha-only graphics context
    context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, nil, kCGImageAlphaOnly);
    
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
