//
//  MPOAuthAPI+TokenAdditionsiPhone.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.13.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import "MPOAuthAPI+KeychainAdditions.h"
#import <Security/Security.h>

#if TARGET_OS_IPHONE && (! TARGET_IPHONE_SIMULATOR)

@interface MPOAuthAPI (TokenAdditionsiPhone)
- (NSString *)findValueFromKeychainUsingName:(NSString *)inName returningItem:(NSDictionary **)outKeychainItemRef;
@end

@implementation MPOAuthAPI (KeychainAdditions)

- (void)addToKeychainUsingName:(NSString *)inName andValue:(NSString *)inValue {
	NSString *serverName = [_baseURL host];
	NSString *securityDomain = [_authenticationURL host];
//	NSString *itemID = [NSString stringWithFormat:@"%@.oauth.%@", [[NSBundle mainBundle] bundleIdentifier], inName];
	NSDictionary *searchDictionary = nil;
	NSDictionary *keychainItemAttributeDictionary = [NSDictionary dictionaryWithObjectsAndKeys:	(id)kSecClassInternetPassword, kSecClass,
																								securityDomain, kSecAttrSecurityDomain,
																								serverName, kSecAttrServer,
																								inName, kSecAttrAccount,
																								kSecAttrAuthenticationTypeDefault, kSecAttrAuthenticationType,
																								[NSNumber numberWithUnsignedLongLong:'oaut'], kSecAttrType,
																								[inValue dataUsingEncoding:NSUTF8StringEncoding], kSecValueData,
													 nil];
	
	
	if ([self findValueFromKeychainUsingName:inName returningItem:&searchDictionary]) {
		NSMutableDictionary *updateDictionary = [keychainItemAttributeDictionary mutableCopy];
		[updateDictionary removeObjectForKey:(id)kSecClass];
		
		SecItemUpdate((CFDictionaryRef)keychainItemAttributeDictionary, (CFDictionaryRef)updateDictionary);
		[updateDictionary release];
	} else {
		OSStatus success = SecItemAdd( (CFDictionaryRef)keychainItemAttributeDictionary, NULL);
		
		if (success == errSecNotAvailable) {
			[NSException raise:@"Keychain Not Available" format:@"Keychain Access Not Currently Available"];
		} else if (success == errSecDuplicateItem) {
			[NSException raise:@"Keychain duplicate item exception" format:@"Item already exists for %@", keychainItemAttributeDictionary];
		}
	}
}

- (NSString *)findValueFromKeychainUsingName:(NSString *)inName {
	return [self findValueFromKeychainUsingName:inName returningItem:NULL];
}

- (NSString *)findValueFromKeychainUsingName:(NSString *)inName returningItem:(NSDictionary **)outKeychainItemRef {
	NSString *foundPassword = nil;
	NSString *serverName = [_baseURL host];
	NSString *securityDomain = [_authenticationURL host];
	NSDictionary *attributesDictionary = nil;
	NSData *foundValue = nil;
	OSStatus status = noErr;
//	NSString *itemID = [NSString stringWithFormat:@"%@.oauth.%@", [[NSBundle mainBundle] bundleIdentifier], inName];
	
	NSMutableDictionary *searchDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:(id)kSecClassInternetPassword, (id)kSecClass,
																							  securityDomain, (id)kSecAttrSecurityDomain,
																							  serverName, (id)kSecAttrServer,
																							  inName, (id)kSecAttrAccount,
																							  (id)kSecMatchLimitOne, (id)kSecMatchLimit,
																							  (id)kCFBooleanTrue, (id)kSecReturnData,
																							  (id)kCFBooleanTrue, (id)kSecReturnAttributes,
																							  (id)kCFBooleanTrue, (id)kSecReturnPersistentRef,
											 nil];

	status = SecItemCopyMatching((CFDictionaryRef)searchDictionary, (CFTypeRef *)&attributesDictionary);		
	foundValue = [attributesDictionary objectForKey:(id)kSecValueData];
	if (outKeychainItemRef) {
		*outKeychainItemRef = attributesDictionary;
	}
	
	if (status == noErr && foundValue) {
		foundPassword = [[NSString alloc] initWithData:foundValue encoding:NSUTF8StringEncoding];
	}
	
	return [foundPassword autorelease];
}

- (void)removeValueFromKeychainUsingName:(NSString *)inName {
	NSDictionary *aKeychainItem = NULL;
	
	[self findValueFromKeychainUsingName:inName returningItem:&aKeychainItem];
	
	if (aKeychainItem) {
		SecItemDelete((CFDictionaryRef)aKeychainItem);
	}
}

@end

#endif TARGET_OS_IPHONE
