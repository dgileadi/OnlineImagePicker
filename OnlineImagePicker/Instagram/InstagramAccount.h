//
//  InstagramAccount.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 9/29/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <InstagramKit/InstagramKit.h>
#import "OnlineImageAccountsController.h"

@interface InstagramAccount : NSObject<OnlineImageAccount>

@property (nonatomic, assign) IKLoginScope scope;

+(InstagramAccount *) sharedInstance;

@end