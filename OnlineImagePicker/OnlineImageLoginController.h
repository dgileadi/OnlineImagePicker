//
//  OnlineImageLoginController.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OnlineImageAccount.h"

/**
 * An abstract base class for login controllers to extend.
 */
@interface OnlineImageLoginController : UIViewController <UIWebViewDelegate>

@property(nonatomic, weak) UIWebView *webView;
@property(nonatomic, weak) UIActivityIndicatorView *spinner;
@property(nonatomic, strong) OnlineAccountLoginComplete completedBlock;
@property(nonatomic) id<OnlineImageAccount> account;

/** Initialize with an account. */
-(id) initWithAccount:(id<OnlineImageAccount>)account completed:(OnlineAccountLoginComplete)completedBlock;

/** *Subclasses must extend:* provide the initial URL for the login page. */
-(NSURL *) loginURL;

/** *Subclasses must extend:* handle a redirect, returning `YES` if it's a login finished redirect and was handled. */
-(BOOL) handleRedirect:(NSURL *)url;

@end
