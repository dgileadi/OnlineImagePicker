//
//  ExampleOnlineImageViewController.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 09/27/2014.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ONlineImagePicker/OnlineImagePicker.h>
#import <M13ProgressSuite/M13ProgressViewRing.h>

@interface ExampleOnlineImageViewController : UIViewController

@property(nonatomic) IBOutlet UIScrollView *scrollView;
@property(nonatomic) IBOutlet UIImageView *imageView;
@property(nonatomic) IBOutlet M13ProgressViewRing *progressView;
@property(nonatomic) id<OnlineImageInfo> imageInfo;

@end
