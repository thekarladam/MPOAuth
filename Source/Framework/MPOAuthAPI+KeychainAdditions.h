//
//  MPOAuthAPI+TokenAdditionsMac.h
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.13.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPOAuthAPI.h"

@interface MPOAuthAPI (KeychainAdditions)

- (void)addToKeychainUsingName:(NSString *)inName andValue:(NSString *)inValue;
- (NSString *)findValueFromKeychainUsingName:(NSString *)inName;
- (void)removeValueFromKeychainUsingName:(NSString *)inName;

@end
