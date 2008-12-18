//
//  MPOAuthAPIKeychainTests.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.18.
//  Copyright 2008 Yahoo. All rights reserved.
//

#import "MPOAuthAPIKeychainTests.h"


@implementation MPOAuthAPIKeychainTests

- (void)setUp {
	_api = [[MPOAuthAPI alloc] init];
}

- (void)tearDown {
	[_api release];
	_api = nil;
}

- (void)testWritingToAndReadingFromKeychain {
	[_api addToKeychainUsingName:@"test_name" andValue:@"test_value"];
	NSString *savedValue = [_api findValueFromKeychainUsingName:@"test_name"];
	STAssertEqualObjects(savedValue, @"test_value", @"The value read from the keychain \"%@\" was different from the one written to the keychain: %@", savedValue, @"test_value");


	[_api addToKeychainUsingName:@"test_name" andValue:@"test_value2"];
	NSString *savedValue2 = [_api findValueFromKeychainUsingName:@"test_name"];
	STAssertEqualObjects(savedValue2, @"test_value2", @"The value read from the keychain \"%@\" was different from the one written to the keychain \"%@\" to overwrite \"%@\"", savedValue, @"test_value2", @"test_value");	

	[_api removeValueFromKeychainUsingName:@"test_name"];
	NSString *deletedValue = [_api findValueFromKeychainUsingName:@"test_name"];
	STAssertNil(deletedValue, @"The value read from the keychain for \"test_name\" should now be nil");
}

@end
