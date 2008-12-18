//
//  MPURLRequestParameterTests.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.18.
//  Copyright 2008 Yahoo. All rights reserved.
//

#import "MPURLRequestParameterTests.h"
#import "MPURLRequestParameter.h"

@implementation MPURLRequestParameterTests

- (void)setUp {
    _parameter = [[MPURLRequestParameter alloc] init];
	_parameter.name = @"simon";
	_parameter.value = @"did not say";
}

- (void)testSetup {
    STAssertEqualObjects(_parameter.name, @"simon", @"The parameter name was incorrectly set to: %@", _parameter.name);
    STAssertEqualObjects(_parameter.value, @"did not say", @"The parameter value was incorrectly set to: %@", _parameter.value);
}

- (void)testURLEncodedNameValuePair {
    STAssertEqualObjects([_parameter HTTPGETParameterString], @"simon=did\%20not\%20say", @"The parameter pair was incorrectly encoded as: %@", [_parameter HTTPGETParameterString]);
}


@end
