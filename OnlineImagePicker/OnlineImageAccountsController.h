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
 * A controller for listing online accounts, and allowing users to log in and out of them.
 */
@interface OnlineImageAccountsController : UINavigationController

/** The accounts this controller manages. */
@property(nonatomic) NSArray *accounts;

/** A toolbar for displaying the Done button. */
@property(nonatomic) IBOutlet UIToolbar *toolbar;

/**
 * Initialize this controller with the given accounts.
 */
-(id) initWithAccounts:(NSArray *)accounts;

@end
