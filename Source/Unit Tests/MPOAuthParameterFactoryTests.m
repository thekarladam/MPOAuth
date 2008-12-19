//
//  MPOAuthParameterFactoryTests.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.18.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import "MPOAuthParameterFactoryTests.h"
#import "MPOAuthCredentialConcreteStore.h"
#import "MPURLRequestParameter.h"

@implementation MPOAuthParameterFactoryTests

- (void)setUp {
	_factory = [[MPOAuthCredentialConcreteStore alloc] init];
}

- (void)testNonceGeneration {
	MPURLRequestParameter *nonceParameter = [_factory oauthNonceParameter];
	STAssertNotNil(nonceParameter, @"A Nonce needs to be successfully generated");
}

- (void)testOAuthVersion {
	MPURLRequestParameter *versionParameter = [_factory oauthVersionParameter];
	STAssertEqualObjects(versionParameter.value, @"1.0", @"OAuth version 1.0 is the only supported version of OAuth currently" );
}


@end
