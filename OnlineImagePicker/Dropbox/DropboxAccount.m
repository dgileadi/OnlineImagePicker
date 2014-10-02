//
//  DropboxAccount.m
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import "DropboxAccount.h"
#import <DropboxSDK.h>
#import <UIKit/UIKit.h>
#import "OnlineImageLoginController.h"


static NSString *kDropboxAppKeyName = @"DropboxAppKey";
static NSString *kDropboxAppSecretName = @"DropboxAppSecret";


@implementation DropboxAccount

+(DropboxAccount *) sharedInstance {
    static DropboxAccount *_sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedInstance = [[DropboxAccount alloc] init];
    });
    return _sharedInstance;
}

-(id) init {
    if (self = [super init])
        [self registerWithDropbox];
    return self;
}

-(void) registerWithDropbox {
    if (![DBSession sharedSession]) {
        NSString *appKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:kDropboxAppKeyName];
        NSString *appSecret = [[NSBundle mainBundle] objectForInfoDictionaryKey:kDropboxAppSecretName];
        if (appKey && appSecret) {
            DBSession *dbSession = [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:kDBRootDropbox];
            [DBSession setSharedSession:dbSession];
        }
    }
}

-(UIImage *) icon {
    return [UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"DropboxIcon" ofType:@"png"]];
}

-(NSString *) description {
    return [[self bundle] localizedStringForKey:@"DropboxAccount" value:@"Dropbox" table:nil];
}

-(NSBundle *) bundle {
    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"OnlineImagePicker" ofType:@"bundle"]];
}

-(BOOL) isLoggedIn {
    return [[DBSession sharedSession] isLinked];
}

-(void) loginFromController:(UINavigationController *)navigationController thenCall:(OnlineAccountLoginComplete)completed {
    [[DBSession sharedSession] linkFromController:navigationController];
}

-(void) logout {
    [[DBSession sharedSession] unlinkAll];
}

@end
