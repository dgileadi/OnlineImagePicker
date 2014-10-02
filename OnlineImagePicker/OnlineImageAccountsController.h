//
//  OnlineImageAccountsController.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/27/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OnlineImageAccount.h"


/**
 * A delegate for OnlineImageAccountsController.
 */
@protocol OnlineImageAccountsDelegate <NSObject>

/**
 * A list of accounts to manage.
 */
-(NSArray *) accounts;

/**
 * Called when the controller is done managing accounts, typically in order to close the controller.
 */
-(void) doneManagingAccounts;

@end


/**
 * A controller for listing online accounts, and allowing users to log in and out of them.
 */
@interface OnlineImageAccountsController : UINavigationController

/**
 * Initialize this controller with a delegate.
 */
-(id) initWithDelegate:(id<OnlineImageAccountsDelegate>)delegate;

@end
