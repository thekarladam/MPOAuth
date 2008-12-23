//
//  MPURLRequestParameterTests.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.18.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import "MPURLRequestParameterTests.h"
#import "MPURLRequestParameter.h"
#import "NSString+URLEscapingAdditions.h"

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
    STAssertEqualObjects([_parameter URLEncodedParameterString], @"simon=did\%20not\%20say", @"The parameter pair was incorrectly encoded as: %@", [_parameter URLEncodedParameterString]);
}

- (void)testEncodedURLParameterString {
    //TODO gather complete set of test chars -> encoded values
    NSString *starter = @"\"<>\%{}[]|\\^`hello #";
    STAssertEqualObjects([starter stringByAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding], @"\%22\%3C\%3E\%25\%7B\%7D\%5B\%5D\%7C\%5C\%5E\%60hello\%20\%23", @"The string was not encoded properly.");
}


@end
