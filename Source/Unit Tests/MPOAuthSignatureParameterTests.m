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
#import "NSString+URLEscapingAdditions.h"

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
	MPOAuthCredentialConcreteStore *mockCredentials = [[MPOAuthCredentialConcreteStore alloc] initWithCredentials:credentialsDictionary forBaseURL:nil];
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

- (void)testHMACSHA1Signature_Core92 {
	STAssertEqualObjects([MPOAuthSignatureParameter HMAC_SHA1SignatureForText:@"bs" usingSecret:@"cs&"],
						 @"egQqG5AJep5sJ7anhXju1unge2I=",
						 @"Generated HMAC_SHA1 Signature is incorrect, Core 9.2");
	
	STAssertEqualObjects([MPOAuthSignatureParameter HMAC_SHA1SignatureForText:@"bs" usingSecret:@"cs&ts"],
						 @"VZVjXceV7JgPq/dOTnNmEfO0Fv8=",
						 @"Generated HMAC_SHA1 Signature is incorrect, Core 9.2");
	
	STAssertEqualObjects([MPOAuthSignatureParameter HMAC_SHA1SignatureForText:@"GET&http%3A%2F%2Fphotos.example.net%2Fphotos&file%3Dvacation.jpg%26oauth_consumer_key%3Ddpf43f3p2l4k3l03%26oauth_nonce%3Dkllo9940pd9333jh%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1191242096%26oauth_token%3Dnnch734d00sl2jdk%26oauth_version%3D1.0%26size%3Doriginal" usingSecret:@"kd94hf93k423kf44&pfkkdhi9sl3r4s00"],
						 @"tR3+Ty81lMeYAr/Fid0kMTYa/WM=",
						 @"Generated HMAC_SHA1 Signature is incorrect, Core 9.2");
	
}

- (void)testURIEscapedGeneratedSignatures_Core941 {
	NSDictionary *credentialsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"abcdefghijklmnopqestuvwxyz", kMPOAuthCredentialConsumerKey,
																					@"djr9rjt0jd78jf88", kMPOAuthCredentialConsumerSecret, nil];
	MPOAuthCredentialConcreteStore *mockCredentials = [[MPOAuthCredentialConcreteStore alloc] initWithCredentials:credentialsDictionary forBaseURL:nil];
	mockCredentials.signatureMethod = @"PLAINTEXT";
	
	mockCredentials.requestToken = @"empty";
	mockCredentials.requestTokenSecret = @"";
	STAssertEqualObjects([mockCredentials.signingKey stringByAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding], @"djr9rjt0jd78jf88%26", @"Generated Signature does not conform to OAuth Core 9.4.1");

	
	mockCredentials.requestTokenSecret = @"jjd999tj88uiths3";
	STAssertEqualObjects([mockCredentials.signingKey stringByAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding], @"djr9rjt0jd78jf88%26jjd999tj88uiths3", @"Generated Signature does not conform to OAuth Core 9.4.1");
	
	mockCredentials.requestTokenSecret = @"jjd99$tj88uiths3";
	STAssertEqualObjects([mockCredentials.signingKey stringByAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding], @"djr9rjt0jd78jf88%26jjd99%2524tj88uiths3", @"Generated Signature does not conform to OAuth Core 9.4.1");
	
	mockCredentials.signatureMethod = @"HMAC-SHA1";
	mockCredentials.requestTokenSecret = @"";
	STAssertEqualObjects(mockCredentials.signingKey, @"djr9rjt0jd78jf88&", @"Generated Signature does not conform to OAuth Core 9.4.1");
	
	mockCredentials.requestTokenSecret = @"jjd999tj88uiths3";
	STAssertEqualObjects(mockCredentials.signingKey, @"djr9rjt0jd78jf88&jjd999tj88uiths3", @"Generated Signature does not conform to OAuth Core 9.4.1");
	
	mockCredentials.requestTokenSecret = @"jjd99$tj88uiths3";
	STAssertEqualObjects(mockCredentials.signingKey, @"djr9rjt0jd78jf88&jjd99%24tj88uiths3", @"Generated Signature does not conform to OAuth Core 9.4.1");	
	
}

- (void)testConcatenationOfRequestElementsForBASEString_Core912 {
	NSURL *testURL = [NSURL URLWithString:@"http://example.com/"];
	MPURLRequestParameter *aParameter = [[[MPURLRequestParameter alloc] initWithName:@"n" andValue:@"v"] autorelease];
	NSMutableArray *parameterArray = [NSMutableArray arrayWithObject:aParameter];
	MPOAuthURLRequest *urlRequest = [[[MPOAuthURLRequest alloc] initWithURL:testURL andParameters:[NSArray arrayWithObject:aParameter]] autorelease];

	NSString *baseString = [MPOAuthSignatureParameter signatureBaseStringUsingParameterString:[MPURLRequestParameter parameterStringForParameters:parameterArray]
																				   forRequest:urlRequest];	
	STAssertEqualObjects(baseString, @"GET&http%3A%2F%2Fexample.com%2F&n%3Dv", @"Base String does not conform to Core 9.1.2");
	
	urlRequest.url = [NSURL URLWithString:@"http://example.com"];
	baseString = [MPOAuthSignatureParameter signatureBaseStringUsingParameterString:[MPURLRequestParameter parameterStringForParameters:parameterArray]
																		 forRequest:urlRequest];
	STAssertEqualObjects(baseString, @"GET&http%3A%2F%2Fexample.com%2F&n%3Dv", @"Base String does not conform to Core 9.1.2");

	urlRequest.HTTPMethod = @"POST";
	urlRequest.url = [NSURL URLWithString:@"https://photos.example.net/request_token"];
	[parameterArray removeAllObjects];
	[parameterArray addObject:[[[MPURLRequestParameter alloc] initWithName:@"oauth_version" andValue:@"1.0"] autorelease]];
	[parameterArray addObject:[[[MPURLRequestParameter alloc] initWithName:@"oauth_consumer_key" andValue:@"dpf43f3p2l4k3l03"] autorelease]];
	[parameterArray addObject:[[[MPURLRequestParameter alloc] initWithName:@"oauth_timestamp" andValue:@"1191242090"] autorelease]];
	[parameterArray addObject:[[[MPURLRequestParameter alloc] initWithName:@"oauth_nonce" andValue:@"hsu94j3884jdopsl"] autorelease]];
	[parameterArray addObject:[[[MPURLRequestParameter alloc] initWithName:@"oauth_signature_method" andValue:@"PLAINTEXT"] autorelease]];
	// This is not part of the test, it's added later by the API, only here to document the discrepancy between the site's test and here
//	[parameterArray addObject:[[[MPURLRequestParameter alloc] initWithName:@"oauth_signature" andValue:@"ignored"] autorelease]]; 
	[parameterArray sortUsingSelector:@selector(compare:)];
	baseString = [MPOAuthSignatureParameter signatureBaseStringUsingParameterString:[MPURLRequestParameter parameterStringForParameters:parameterArray]
																		 forRequest:urlRequest];
	STAssertEqualObjects(baseString, 
						 @"POST&https%3A%2F%2Fphotos.example.net%2Frequest_token&oauth_consumer_key%3Ddpf43f3p2l4k3l03%26oauth_nonce%3Dhsu94j3884jdopsl%26oauth_signature_method%3DPLAINTEXT%26oauth_timestamp%3D1191242090%26oauth_version%3D1.0",
						 @"Base String does not conform to Core 9.1.2");
	
	urlRequest.HTTPMethod = @"GET";
	urlRequest.url = [NSURL URLWithString:@"http://photos.example.net/photos"];
	[parameterArray removeAllObjects];
	[parameterArray addObject:[[[MPURLRequestParameter alloc] initWithName:@"oauth_version" andValue:@"1.0"] autorelease]];
	[parameterArray addObject:[[[MPURLRequestParameter alloc] initWithName:@"oauth_consumer_key" andValue:@"dpf43f3p2l4k3l03"] autorelease]];
	[parameterArray addObject:[[[MPURLRequestParameter alloc] initWithName:@"oauth_token" andValue:@"nnch734d00sl2jdk"] autorelease]];
	[parameterArray addObject:[[[MPURLRequestParameter alloc] initWithName:@"oauth_timestamp" andValue:@"1191242096"] autorelease]];
	[parameterArray addObject:[[[MPURLRequestParameter alloc] initWithName:@"oauth_nonce" andValue:@"kllo9940pd9333jh"] autorelease]];
	[parameterArray addObject:[[[MPURLRequestParameter alloc] initWithName:@"oauth_signature_method" andValue:@"HMAC-SHA1"] autorelease]];
	[parameterArray addObject:[[[MPURLRequestParameter alloc] initWithName:@"file" andValue:@"vacation.jpg"] autorelease]];
	[parameterArray addObject:[[[MPURLRequestParameter alloc] initWithName:@"size" andValue:@"original"] autorelease]];
	// This is not part of the test, it's added later by the API, only here to document the discrepancy between the site's test and here
	//	[parameterArray addObject:[[[MPURLRequestParameter alloc] initWithName:@"oauth_signature" andValue:@"ignored"] autorelease]];
	[parameterArray sortUsingSelector:@selector(compare:)];
	baseString = [MPOAuthSignatureParameter signatureBaseStringUsingParameterString:[MPURLRequestParameter parameterStringForParameters:parameterArray]
																		 forRequest:urlRequest];
	STAssertEqualObjects(baseString, 
						 @"GET&http%3A%2F%2Fphotos.example.net%2Fphotos&file%3Dvacation.jpg%26oauth_consumer_key%3Ddpf43f3p2l4k3l03%26oauth_nonce%3Dkllo9940pd9333jh%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1191242096%26oauth_token%3Dnnch734d00sl2jdk%26oauth_version%3D1.0%26size%3Doriginal",
						 @"Base String does not conform to Core 9.1.2");
	
}


@end
