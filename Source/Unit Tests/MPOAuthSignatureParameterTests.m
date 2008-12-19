//
//  MPOAuthSignatureParameterTests.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.18.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import "MPOAuthSignatureParameterTests.h"
#import "MPOAuthURLRequest.h"
#import "MPOAuthCredentialConcreteStore.h"

@implementation MPOAuthSignatureParameterTests

- (void)testPlainTextSignature {
	_signatureParameter = [[MPOAuthSignatureParameter alloc] initWithText:@"abcdefg" andSecret:@"123456789" forRequest:nil usingMethod:kMPOAuthSignatureMethodPlaintext];
	
	STAssertEqualObjects(_signatureParameter.value, @"123456789", @"The plain text signature method failed, the expected value was 123456789");
	[_signatureParameter release];
	_signatureParameter = nil;
}


	
- (void)testHMACSHA1Signature {
	NSMutableArray *parameters = [NSMutableArray arrayWithObject:[[[MPURLRequestParameter alloc] initWithName:@"file" andValue:@"vacation.jpg"] autorelease]];
	MPOAuthURLRequest *request = [[MPOAuthURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://photots.example.net/photos"]
														  andParameters:parameters];
	
	NSDictionary *credentialsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"abcdefghijklmnopqestuvwxyz", kMPOAuthCredentialConsumerKey, nil];
	MPOAuthCredentialConcreteStore *mockCredentials = [[MPOAuthCredentialConcreteStore alloc] initWithCredentials:credentialsDictionary];
	mockCredentials.signatureMethod = @"HMAC-SHA1";
	
	[parameters addObjectsFromArray:[mockCredentials oauthParameters]];
	[parameters sortUsingSelector:@selector(compare:)];
	
	MPURLRequestParameter *nonce = [parameters objectAtIndex:2];
	MPURLRequestParameter *timestamp = [parameters objectAtIndex:4];

	STAssertEqualObjects( nonce.name, @"oauth_nonce", @"This is not the nonce you're looking for, it's %@", nonce.name);
	STAssertEqualObjects( timestamp.name, @"oauth_timestamp", @"This is not the timestamp you're looking for, it's %@", timestamp.name);

	[nonce setValue:@"A0652B19-B977-45F1-A0B9-7C8621F95871"]; // set an explicit nonce
	[timestamp setValue:@"0"]; // set timestamp to 0
	
	_signatureParameter = [[MPOAuthSignatureParameter alloc] initWithText:[MPURLRequestParameter parameterStringForParameters:parameters] andSecret:@"123456789" forRequest:request usingMethod:kMPOAuthSignatureMethodHMACSHA1];
	
	STAssertEqualObjects(_signatureParameter.value, @"9WSQnB6gafEmHUlzF0cLtN0Tfvk=", @"The plain text signature method failed, the expected value was \"/AvKxaXD0WjtRZc8G6H9ENWTX5Q=\"");

	[mockCredentials release];
	[_signatureParameter release];
	_signatureParameter = nil;
}

@end
