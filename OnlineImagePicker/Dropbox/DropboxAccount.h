//
//  DropboxAccount.h
//  OnlineImagePicker
//
//  Created by David Gileadi on 10/1/14.
//  Copyright (c) 2014 David Gileadi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnlineImageAccount.h"

/**
 * Supports user authentication for Dropbox.
 */
@interface DropboxAccount : NSObject <OnlineImageAccount>

/** The single shared instance of this class. */
+(DropboxAccount *) sharedInstance;

@end
