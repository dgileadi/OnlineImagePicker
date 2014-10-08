//
//  ExampleOnlineImagePickerController.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/7/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "ExampleOnlineImagePickerController.h"
#import "ExampleOnlineImageViewController.h"

@interface ExampleOnlineImagePickerController()
@property(nonatomic) id<OnlineImageInfo> info;
@property(nonatomic) UIImage *thumbnail;
@end

@implementation ExampleOnlineImagePickerController

#pragma mark - OnlineImagePickerDelegate

-(void) imagePickedWithInfo:(id<OnlineImageInfo>)info andThumbnail:(UIImage *)thumbnail {
    self.info = info;
    self.thumbnail = thumbnail;
    [self performSegueWithIdentifier:@"ShowImage" sender:self];
}

// this won't ever be called since this is the root view controller
-(void) cancelledPicker {
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ExampleOnlineImageViewController *destination = segue.destinationViewController;
    destination.imageView.image = self.thumbnail;
    destination.imageInfo = self.info;
}

@end
