//
//  OnlineImageLoginController.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "OnlineImageLoginController.h"

@implementation OnlineImageLoginController

-(id) initWithAccount:(id<OnlineImageAccount>)account completed:(OnlineAccountLoginComplete)completedBlock {
    if (self = [super init]) {
        self.account = account;
        self.completedBlock = completedBlock;
    }
    return self;
}

-(NSURL *) loginURL {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(BOOL) handleRedirect:(NSURL *)url {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
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
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner = spinner;
    [spinner startAnimating];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    self.navigationItem.rightBarButtonItem = item;
    
    [self loadLoginURL];
}

-(void) loadLoginURL {
    NSURL *url = [self loginURL];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([self handleRedirect:request.URL]) {
        [self.navigationController popViewControllerAnimated:YES];
        self.completedBlock(nil, self.account);
        return NO;
    }
    return YES;
}

-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.navigationController popViewControllerAnimated:YES];
    self.completedBlock(error, self.account);
}

-(void) webViewDidStartLoad:(UIWebView *)webView {
    self.spinner.hidden = NO;
}

-(void) webViewDidFinishLoad:(UIWebView *)webView {
    self.spinner.hidden = YES;
}

@end
