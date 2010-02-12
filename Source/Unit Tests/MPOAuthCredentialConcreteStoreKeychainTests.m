//
//  MPOAuthCredentialConcreteStoreKeychainTests.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.18.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import "MPOAuthCredentialConcreteStoreKeychainTests.h"


@implementation MPOAuthCredentialConcreteStoreKeychainTests

- (void)setUp {
	store_ = [[MPOAuthCredentialConcreteStore alloc] initWithCredentials:nil forBaseURL:[NSURL URLWithString:@"http://example.com/oauth"]];
}

- (void)tearDown {
	[store_ release];
	store_ = nil;
}

- (void)testWritingToAndReadingFromKeychain {
	NSString *testValue = [store_ findValueFromKeychainUsingName:@"test_name"];
	STAssertNil(testValue, @"The value read from the keychain for \"test_name\" should start as nil");
	
	[store_ addToKeychainUsingName:@"test_name" andValue:@"test_value"];
	NSString *savedValue = [store_ findValueFromKeychainUsingName:@"test_name"];
	STAssertEqualObjects(savedValue, @"test_value", @"The value read from the keychain \"%@\" was different from the one written to the keychain: %@", savedValue, @"test_value");


	[store_ addToKeychainUsingName:@"test_name" andValue:@"test_value2"];
	NSString *savedValue2 = [store_ findValueFromKeychainUsingName:@"test_name"];
	STAssertEqualObjects(savedValue2, @"test_value2", @"The value read from the keychain \"%@\" was different from the one written to the keychain \"%@\" to overwrite \"%@\"", savedValue, @"test_value2", @"test_value");	

	[store_ removeValueFromKeychainUsingName:@"test_name"];
	NSString *deletedValue = [store_ findValueFromKeychainUsingName:@"test_name"];
	STAssertNil(deletedValue, @"The value read from the keychain for \"test_name\" should now be nil");
}

@end
