//
//  OnlineImageAccountsController.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/27/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OnlineImageAccount;

/**
 * Called when a page of results is returned from an image source.
 * The parameters are an array of OnlineImageInfo objects, up to pageSize in length, and the source of the results.
 */
typedef void(^OnlineAccountLoginComplete)(NSError *error, id<OnlineImageAccount>account);


/**
 * Implement this protocol to support authenticating to an online account.
 */
@protocol OnlineImageAccount <NSObject>

-(UIImage *) icon;
-(NSString *) description;
-(BOOL) isLoggedIn;
-(void) loginFromController:(UINavigationController *)navigationController thenCall:(OnlineAccountLoginComplete)completed;
-(void) logout;

@end


@interface OnlineImageAccountsController : UINavigationController

@end
