//
//  FacebookAccount.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/29/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "FacebookAccount.h"
#import <UIKit/UIKit.h>
#import <FacebookSDK.h>

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
        // if there's a cached session, just open the session silently, without showing the user the login UI
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"user_photos"]
                                               allowLoginUI:NO
                                          completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                              [self sessionStateChanged:session state:state error:error];
                                          }];
        }
    }
    return self;
}

-(void) sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error {
    // forward to the AppDelegate if applicable
    id appDelegate = [UIApplication sharedApplication].delegate;
    if ([appDelegate respondsToSelector:@selector(sessionStateChanged:state:error:)])
        [appDelegate sessionStateChanged:session state:state error:error];
    else if (error && [FBErrorUtility shouldNotifyUserForError:error]) {
        NSString *alertTitle = @"Something went wrong";
        NSString *alertText = [FBErrorUtility userMessageForError:error];
        [self showMessage:alertText withTitle:alertTitle];
    }
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
    return FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended;
}

-(void) loginFromController:(UINavigationController *)navigationController thenCall:(OnlineAccountLoginComplete)completed {
    if (FBSession.activeSession.state != FBSessionStateOpen
        && FBSession.activeSession.state != FBSessionStateOpenTokenExtended) {
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"user_photos"] allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
            [self sessionStateChanged:session state:state error:error];
            completed(error, self);
        }];
    }
}

-(void) logout {
    [FBSession.activeSession closeAndClearTokenInformation];
}

@end
