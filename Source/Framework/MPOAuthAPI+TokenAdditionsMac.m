//
//  MPOAuthAPI+TokenAdditionsMac.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.13.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import "MPOAuthAPI+TokenAdditions.h"

#if !TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

@interface MPOAuthAPI (TokenAdditionsMac)
- (NSString *)findValueFromKeychainUsingName:(NSString *)inName returningItem:(SecKeychainItemRef *)outKeychainItemRef;
@end

@implementation MPOAuthAPI (TokenAdditions)

- (void)addToKeychainUsingName:(NSString *)inName andValue:(NSString *)inValue {
	NSString *serverName = [_baseURL host];
	NSString *securityDomain = [_authenticationURL host];
	
	SecKeychainAddInternetPassword(NULL /* default keychain */,
								   [serverName length], [serverName UTF8String],
								   [securityDomain length], [securityDomain UTF8String],
								   [inName length], [inName UTF8String],	/* account name */
								   0, NULL,	/* path */
								   0,
								   'oaut'	/* OAuth, not an official OSType code */,
								   kSecAuthenticationTypeDefault,
								   [inValue length], [inValue UTF8String],
								   NULL);
}

- (NSString *)findValueFromKeychainUsingName:(NSString *)inName {
	return [self findValueFromKeychainUsingName:inName returningItem:NULL];
}

- (NSString *)findValueFromKeychainUsingName:(NSString *)inName returningItem:(SecKeychainItemRef *)outKeychainItemRef {
	NSString *foundPassword = nil;
	NSString *serverName = [_baseURL host];
	NSString *securityDomain = [_authenticationURL host];
	
	UInt32 passwordLength = 0;
	const char *passwordString = NULL;
	
	OSStatus status = SecKeychainFindInternetPassword(NULL	/* default keychain */,
													  [serverName length], [serverName UTF8String],
													  [securityDomain length], [securityDomain UTF8String],
													  [inName length], [inName UTF8String],
													  0, NULL,	/* path */
													  0,
													  (SecProtocolType)NULL,
													  (SecAuthenticationType)NULL,
													  (UInt32 *)&passwordLength,
													  (void **)&passwordString,
													  outKeychainItemRef);
	
	if (status == noErr && passwordLength) {
		NSData *passwordStringData = [NSData dataWithBytes:passwordString length:passwordLength];
		foundPassword = [[NSString alloc] initWithData:passwordStringData encoding:NSUTF8StringEncoding];
	}
	
	return [foundPassword autorelease];
}

- (void)removeValueFromKeychainUsingName:(NSString *)inName {
	SecKeychainItemRef aKeychainItem = NULL;
	
	[self findValueFromKeychainUsingName:inName returningItem:&aKeychainItem];
	
	if (aKeychainItem) {
		SecKeychainItemDelete(aKeychainItem);
	}
}

@end

#endif
