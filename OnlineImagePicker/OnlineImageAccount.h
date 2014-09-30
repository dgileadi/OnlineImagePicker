//
//  OnlineImageAccount.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/30/14.
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

/** An icon to display in the list of accounts. */
-(UIImage *) icon;

/** A description to display in the list of accounts. */
-(NSString *) description;

/** Whether the account is already logged in. Accounts should persist credentials as long as practible. */
-(BOOL) isLoggedIn;

/**
 * Perform an interactive login, then call a handler with the result. Accounts should typically push a controller onto
 * the given navigation controller to perform the login, then pop the controller off again when finished.
 *
 * @param navigationController A UINavigationController to push the login controller onto.
 * @param completedBlock Call this block when login is finished (or when it fails).
 */
-(void) loginFromController:(UINavigationController *)navigationController thenCall:(OnlineAccountLoginComplete)completedBlock;

/**
 * Silently log out.
 */
-(void) logout;

@end