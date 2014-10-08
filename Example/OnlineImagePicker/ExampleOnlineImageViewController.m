//
//  ExampleOnlineImageViewController.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 09/27/2014.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "ExampleOnlineImageViewController.h"
#import <M13ProgressSuite/M13ProgressViewRing.h>

@interface ExampleOnlineImageViewController ()

@end

@implementation ExampleOnlineImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void) setImageInfo:(id<OnlineImageInfo>)imageInfo {
    _imageInfo = imageInfo;
    self.progressView.hidden = NO;
    self.progressView.indeterminate = YES;
    self.scrollView.hidden = YES;
    [imageInfo loadFullSizeWithProgress:^(double progress) {
        self.progressView.indeterminate = NO;
        [self.progressView setProgress:progress animated:YES];
    } completed:^(UIImage *image, NSError *error) {
        self.progressView.hidden = YES;
        self.scrollView.hidden = NO;
        self.imageView.image = image;
        self.scrollView.contentSize = image.size;
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error loading full-sized image" message:[error description] delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

@end
