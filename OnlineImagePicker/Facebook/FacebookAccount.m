//
//  FacebookAccount.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/29/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "FacebookAccount.h"
#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface FacebookAccount()

@property(nonatomic) FBSDKLoginManager *loginManager;

@end

@implementation FacebookAccount

+(FacebookAccount *) sharedInstance {
    static FacebookAccount *_sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedInstance = [[FacebookAccount alloc] init];
    });
    return _sharedInstance;
}

-(id) init {
    if (self = [super init]) {
        self.loginManager = [[FBSDKLoginManager alloc] init];
    }
    return self;
}

-(void) showMessage:(NSString *)message withTitle:(NSString *)title {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alertView.alertViewStyle = UIAlertViewStyleDefault;
    [alertView show];
}

-(UIImage *) icon {
    return [UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"FacebookIcon" ofType:@"png"]];
}

-(NSString *) description {
    return [[self bundle] localizedStringForKey:@"FacebookAccount" value:@"Facebook" table:nil];
}

-(NSBundle *) bundle {
    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"OnlineImagePicker" ofType:@"bundle"]];
}

-(BOOL) isLoggedIn {
    return [[FBSDKAccessToken currentAccessToken] hasGranted:@"user_photos"];
}

-(void) loginFromController:(UINavigationController *)navigationController thenCall:(OnlineAccountLoginComplete)completed {
    if (![self isLoggedIn]) {
        [self.loginManager logInWithReadPermissions:@[@"user_photos"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            
            completed(error, self);
        }];
    }
}

-(void) logout {
    [self.loginManager logOut];
}

@end
