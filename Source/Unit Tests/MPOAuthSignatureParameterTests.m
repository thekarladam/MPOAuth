//
//  MPOAuthSignatureParameterTests.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.18.
//  Copyright 2008 Yahoo. All rights reserved.
//

#import "MPOAuthSignatureParameterTests.h"


@implementation MPOAuthSignatureParameterTests

- (void)testPlainTextSignature {
	_signatureParameter = [[MPOAuthSignatureParameter alloc] initWithText:@"abcdefg" andSecret:@"123456789" forRequest:nil usingMethod:kMPOAuthSignatureMethodPlaintext];
	
	STAssertEqualObjects(_signatureParameter.value, @"123456789", @"The plain text signature method failed, the expected value was 123456789");
	[_signatureParameter release];
	_signatureParameter = nil;
}


	
- (void)testHMACSHA1Signature {
//	NSArray *parameters = [NSArray arrayWithObject:[[[MPURLRequestParameter alloc] initWithName:@"file" andValue:@"vacation.jpg"] autorelease]];
//	MPOAuthURLRequest *request = [[MPOAuthURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://photots.example.net/photos"]
//														  andParameters:parameters];
//	
//	_signatureParameter = [[MPOAuthSignatureParameter alloc] initWithText:@"abcdefg" andSecret:@"123456789" forRequest:nil usingMethod:kMPOAuthSignatureMethodHMACSHA1];
//	
//	STAssertEqualObjects(_signatureParameter.value, @"123456789", @"The plain text signature method failed, the expected value was 123456789");
//	[_signatureParameter release];
//	_signatureParameter = nil;
}

@end
