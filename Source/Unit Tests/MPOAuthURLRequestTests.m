//
//  MPOAuthURLRequestTests.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.18.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import "MPOAuthURLRequestTests.h"
#import "MPOAuthAPI.h"
#import "MPOAuthCredentialConcreteStore.h"
#import "MPURLRequestParameter.h"
#import "NSString+URLEscapingAdditions.h"

@implementation MPOAuthURLRequestTests

- (void)setUp {
	NSDictionary *credentials = [NSDictionary dictionaryWithObjectsAndKeys:	@"dpf43f3p2l4k3l03", kMPOAuthCredentialConsumerKey,
								 @"kd94hf93k423kf44", kMPOAuthCredentialConsumerSecret,
								 nil];
	MPOAuthCredentialConcreteStore *credentialStore = [[MPOAuthCredentialConcreteStore alloc] initWithCredentials:credentials forBaseURL:nil];
	credentialStore.signatureMethod = @"PLAINTEXT";
	
	NSURL *url = [NSURL URLWithString:@"http://example.com/request_token"];
	_request = [[MPOAuthURLRequest alloc] initWithURL:url andParameters:nil];
}

- (void)testNSURLParameterEncoding_Core51 {	
	STAssertEqualObjects([@"abcABC123" stringByAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding],
						 @"abcABC123", @"Incorrectly encoded Parameter String, Core 5.1");
	
	STAssertEqualObjects([@"-._~" stringByAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding],
						 @"-._~", @"Incorrectly Encoded Parameter String, Core 5.1");
	
	STAssertEqualObjects([@"%" stringByAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding],
						 @"%25", @"Incorrectly Encoded Parameter String, Core 5.1");
	
	STAssertEqualObjects([@"+" stringByAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding],
						 @"%2B", @"Incorrectly Encoded Parameter String, Core 5.1");

	STAssertEqualObjects([@"&=*" stringByAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding],
						 @"%26%3D%2A", @"Incorrectly Encoded Parameter String, Core 5.1");

	STAssertEqualObjects([@"\n" stringByAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding],
						 @"%0A", @"Incorrectly Encoded Parameter String, Core 5.1");
	
	STAssertEqualObjects([@" " stringByAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding],
						 @"%20", @"Incorrectly Encoded Parameter String, Core 5.1");

	
	STAssertEqualObjects([@"\x7F" stringByAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding],
						 @"%7F", @"Incorrectly Encoded Parameter String, Core 5.1");

//	STAssertEqualObjects([@"\u80" stringByAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//						 @"%C2%80", @"Incorrectly Encoded Parameter String, Core 5.1");

	STAssertEqualObjects([@"\u3001" stringByAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding],
						 @"%E3%80%81", @"Incorrectly Encoded Parameter String, Core 5.1");

}

- (void)testNormalizeRequestParameters_Core911 {
	NSMutableArray *parameterArray = [NSMutableArray arrayWithCapacity:10];
	
	MPURLRequestParameter *nameParameter = [[[MPURLRequestParameter alloc] initWithName:@"name" andValue:nil] autorelease];
	STAssertEqualObjects([nameParameter URLEncodedParameterString], @"name=", @"Incorrectly Normalized Request Parameters, Core 9.1.1");
	
	MPURLRequestParameter *aParameter = [[[MPURLRequestParameter alloc] initWithName:@"a" andValue:@"b"] autorelease];
	STAssertEqualObjects([aParameter URLEncodedParameterString], @"a=b", @"Incorrectly Normalized Request Parameters, Core 9.1.1");

	MPURLRequestParameter *anotherParameter = [[[MPURLRequestParameter alloc] initWithName:@"c" andValue:@"d"] autorelease];
	[parameterArray addObject:aParameter];
	[parameterArray addObject:anotherParameter];
	STAssertEqualObjects([MPURLRequestParameter parameterStringForParameters:parameterArray], @"a=b&c=d", @"Incorrectly Normalized Request Parameters, Core 9.1.1");
	
	aParameter.value = @"x!y";
	anotherParameter.name = @"a";
	anotherParameter.value = @"x y"; // the test cases online use + as space
	[parameterArray sortUsingSelector:@selector(compare:)];
	STAssertEqualObjects([MPURLRequestParameter parameterStringForParameters:parameterArray], @"a=x%20y&a=x%21y", @"Incorrectly Normalized Request Parameters, Core 9.1.1");
		
	aParameter.name = @"x!y";
	aParameter.value = @"a";
	anotherParameter.name  = @"x";
	anotherParameter.value = @"a";
	[parameterArray sortUsingSelector:@selector(compare:)];
	STAssertEqualObjects([MPURLRequestParameter parameterStringForParameters:parameterArray], @"x=a&x%21y=a", @"Incorrectly Normalized Request Parameters, Core 9.1.1");	
}

- (void)testParameterDictionaries {
	NSDictionary *parameterDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"b", @"a", @"d", @"c", nil];
	STAssertEqualObjects([MPURLRequestParameter parameterStringForDictionary:parameterDictionary], @"a=b&c=d", @"Incorrectly Normalized Request Parameters, Core 9.1.1");
		
	parameterDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"a", @"x!y", @"a", @"x", nil];
	NSArray *parameters = [MPURLRequestParameter parametersFromDictionary:parameterDictionary];
	parameters = [parameters sortedArrayUsingSelector:@selector(compare:)];
	STAssertEqualObjects([MPURLRequestParameter parameterStringForParameters:parameters], @"x=a&x%21y=a", @"Incorrectly Normalized Request Parameters, Core 9.1.1");
}

@end
