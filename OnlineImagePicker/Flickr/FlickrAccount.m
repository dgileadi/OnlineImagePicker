//
//  FlickrAccount.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/6/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "FlickrAccount.h"
#import "OnlineImageLoginController.h"
#import <FlickrKit/FlickrKit.h>


static NSString *kFlickrAPIKeyName = @"FlickrAPIKey";
static NSString *kFlickrSecretName = @"FlickrSecret";


@interface FlickrLoginController : OnlineImageLoginController
@property (nonatomic, retain) FKDUNetworkOperation *authOp;
@end


@implementation FlickrAccount

+(FlickrAccount *) sharedInstance {
    static FlickrAccount *_sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedInstance = [[FlickrAccount alloc] init];
    });
    return _sharedInstance;
}

-(id) init {
    if (self = [super init])
        [self registerWithFlickrKit];
    return self;
}

-(void) registerWithFlickrKit {
    if (![FlickrKit sharedFlickrKit].apiKey) {
        NSString *apiKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:kFlickrAPIKeyName];
        NSString *secret = [[NSBundle mainBundle] objectForInfoDictionaryKey:kFlickrSecretName];
        if (apiKey && secret)
            [[FlickrKit sharedFlickrKit] initializeWithAPIKey:apiKey sharedSecret:secret];
    }
}

-(UIImage *) icon {
    return [UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"FlickrIcon" ofType:@"png"]];
}

-(NSString *) description {
    return [[self bundle] localizedStringForKey:@"FlickrAccount" value:@"Flickr" table:nil];
}

-(NSBundle *) bundle {
    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"OnlineImagePicker" ofType:@"bundle"]];
}

-(BOOL) isLoggedIn {
    return [FlickrKit sharedFlickrKit].authorized;
}

-(void) loginFromController:(UINavigationController *)navigationController thenCall:(OnlineAccountLoginComplete)completed {
    FlickrLoginController *controller = [[FlickrLoginController alloc] initWithAccount:self completed:completed];
    [navigationController pushViewController:controller animated:YES];
}

-(void) logout {
    [[FlickrKit sharedFlickrKit] logout];
}

@end


@implementation FlickrLoginController

-(NSURL *) loginURL {
    return nil;
}

-(void) loadLoginURL {
    NSString *callbackURLString = @"flickrkit://auth";
    self.authOp = [[FlickrKit sharedFlickrKit] beginAuthWithCallbackURL:[NSURL URLWithString:callbackURLString] permission:FKPermissionRead completion:^(NSURL *flickrLoginPageURL, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:flickrLoginPageURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
                [self.webView loadRequest:urlRequest];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        });
    }];
}

-(BOOL) handleRedirect:(NSURL *)url {
    if ([url.scheme isEqual:@"flickrkit"]) {
        [[FlickrKit sharedFlickrKit] completeAuthWithURL:url completion:^(NSString *userName, NSString *userId, NSString *fullName, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                }
            });
        }];
        return YES;
    }
    return NO;
}

-(void) viewWillDisappear:(BOOL)animated {
    [self.authOp cancel];
    [super viewWillDisappear:animated];
}

@end
