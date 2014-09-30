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


@interface InstagramLoginController : UIViewController <UIWebViewDelegate>

@property(nonatomic, weak) UIWebView *webView;
@property(nonatomic, strong) OnlineAccountLoginComplete completedBlock;
@property(nonatomic) InstagramAccount *account;

-(id) initWithAccount:(InstagramAccount *)account completed:(OnlineAccountLoginComplete)completedBlock;

@end


@implementation InstagramAccount

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
    return [[InstagramEngine sharedEngine] accessToken] != nil;
}

-(void) loginFromController:(UINavigationController *)navigationController thenCall:(OnlineAccountLoginComplete)completed {
    InstagramLoginController *controller = [[InstagramLoginController alloc] initWithAccount:self completed:completed];
    [navigationController pushViewController:controller animated:YES];
}

-(void) logout {
    // TODO: once InstagramKit releases a new version, use the logout method from InstagramEngine instead
    
    //    Clear all cookies so the next time the user wishes to switch accounts,
    //    they can do so
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [InstagramEngine sharedEngine].accessToken = nil;
}

@end


@implementation InstagramLoginController

-(id) initWithAccount:(InstagramAccount *)account completed:(OnlineAccountLoginComplete)completedBlock {
    if (self = [super init]) {
        self.account = account;
        self.completedBlock = completedBlock;
    }
    return self;
}

-(void) viewDidLoad {
    [super viewDidLoad];
    
    if (!self.webView) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        webView.scrollView.bounces = NO;
        webView.contentMode = UIViewContentModeScaleAspectFit;
        webView.delegate = self;
        
        [self.view addSubview:webView];
        self.webView = webView;
    }
    
    NSDictionary *configuration = [InstagramEngine sharedEngineConfiguration];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=token", configuration[kInstagramKitAuthorizationUrlConfigurationKey], configuration[kInstagramKitAppClientIdConfigurationKey], configuration[kInstagramKitAppRedirectUrlConfigurationKey]]];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

-(void) viewWillDisappear:(BOOL)animated {
    [[InstagramEngine sharedEngine] cancelLogin];
}

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *URLString = [request.URL absoluteString];
    if ([URLString hasPrefix:[[InstagramEngine sharedEngine] appRedirectURL]]) {
        NSString *delimiter = @"access_token=";
        NSArray *components = [URLString componentsSeparatedByString:delimiter];
        if (components.count > 1) {
            NSString *accessToken = [components lastObject];
NSLog(@"Instagram ACCESS TOKEN = %@", accessToken);
            [[InstagramEngine sharedEngine] setAccessToken:accessToken];
            
            [self.navigationController popViewControllerAnimated:YES];
            self.completedBlock(nil, self.account);
        }
        return NO;
    }
    return YES;
}

-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.navigationController popViewControllerAnimated:YES];
    self.completedBlock(error, self.account);
}

@end