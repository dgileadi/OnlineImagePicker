//
//  InstagramAccount.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/29/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "InstagramAccount.h"
#import <UIKit/UIKit.h>
#import <InstagramKit/InstagramEngine.h>
#import "OnlineImageLoginController.h"


static const NSString *kInstagramAccessTokenKey = @"OnlineImagePicker_InstagramAccessToken";


@interface InstagramLoginController : OnlineImageLoginController

@end


@implementation InstagramAccount

+(InstagramAccount *) sharedInstance {
    static InstagramAccount *_sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedInstance = [[InstagramAccount alloc] init];
    });
    return _sharedInstance;
}

+(NSString *) storedAccessToken {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kInstagramAccessTokenKey];
}

+(void) setStoredAccessToken:(NSString *)token {
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:kInstagramAccessTokenKey];
}

-(UIImage *) icon {
    return [UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"InstagramIcon" ofType:@"png"]];
}

-(NSString *) description {
    return [[self bundle] localizedStringForKey:@"InstagramAccount" value:@"Instagram" table:nil];
}

-(NSBundle *) bundle {
    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"OnlineImagePicker" ofType:@"bundle"]];
}

-(BOOL) isLoggedIn {
    if (![[InstagramEngine sharedEngine] accessToken]) {
        [[InstagramEngine sharedEngine] setAccessToken:[InstagramAccount storedAccessToken]];
    }
    return [[InstagramEngine sharedEngine] accessToken] != nil;
}

-(void) loginFromController:(UINavigationController *)navigationController thenCall:(OnlineAccountLoginComplete)completed {
    InstagramLoginController *controller = [[InstagramLoginController alloc] initWithAccount:self completed:completed];
    [navigationController pushViewController:controller animated:YES];
}

-(void) logout {
    [InstagramEngine sharedEngine].accessToken = nil;
    [InstagramAccount setStoredAccessToken:nil];
    
    // clear all cookies so the next time the user wishes to switch accounts, they can do so
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        if ([cookie.domain containsString:@"instagram"])
            [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end


@implementation InstagramLoginController

-(NSURL *) loginURL {
    NSDictionary *configuration = [InstagramEngine sharedEngineConfiguration];
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=token", configuration[kInstagramKitAuthorizationUrlConfigurationKey], configuration[kInstagramKitAppClientIdConfigurationKey], configuration[kInstagramKitAppRedirectUrlConfigurationKey]]];
}

-(BOOL) handleRedirect:(NSURL *)url {
    NSString *URLString = [url absoluteString];
    if ([URLString hasPrefix:[[InstagramEngine sharedEngine] appRedirectURL]]) {
        NSString *delimiter = @"access_token=";
        NSArray *components = [URLString componentsSeparatedByString:delimiter];
        if (components.count > 1) {
            NSString *accessToken = [components lastObject];
            [[InstagramEngine sharedEngine] setAccessToken:accessToken];
            [InstagramAccount setStoredAccessToken:accessToken];
        }
        return YES;
    }
    return NO;
}

-(void) viewWillDisappear:(BOOL)animated {
    [[InstagramEngine sharedEngine] cancelLogin];
}

@end