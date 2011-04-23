//
//  NSString+URLAdditionsTests.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 09.01.29.
//  Copyright 2009 matrixPointer. All rights reserved.
//

#import "NSString+URLAdditionsTests.h"
#import "MPURLRequestParameter.h"
#import "NSURL+MPURLParameterAdditions.h"
#import "NSString+URLEscapingAdditions.h"

@implementation NSString_URLAdditionsTests

- (void)testDomainMatching {
	NSURL *aURLToDomainMatch = nil;
	NSString *domainName = @".apple.com";
	NSArray *urlsThatShouldMatch = [NSArray arrayWithObjects:@"http://apple.com", @"http://apple.com/imac", @"http://www.apple.com", @"http://itunes.apple.com", nil];
	NSArray *urlsThatShouldNotMatch = [NSArray arrayWithObjects:@"http://macnn.com", @"http://crabapple.com", @"http://apple.crabapple.com", nil];
	
	for (NSString *aURLString in urlsThatShouldMatch) {
		aURLToDomainMatch = [NSURL URLWithString:aURLString];
		STAssertTrue([aURLToDomainMatch domainMatches:domainName], @"The URL's fully quantified domain name %@ should be a match for %@", aURLToDomainMatch, domainName);
	}
	
	for (NSString *aURLString in urlsThatShouldNotMatch) {
		aURLToDomainMatch = [NSURL URLWithString:aURLString];
		STAssertFalse([aURLToDomainMatch domainMatches:domainName], @"The URL's fully quantified domain name %@ should not be a match for %@", aURLToDomainMatch, domainName);

	}
	
}

- (void)testIsIPAddress {
	NSArray *possibleIPsToMatch = [NSArray arrayWithObjects:@"192.168.1.1", @"17.251.200.70", @"68.180.206.184", nil];
	NSArray *possibleIPsToNotMatch = [NSArray arrayWithObjects:@"999.999.1.1", @"666.666", @"42", nil];
	
	for (NSString *anIP in possibleIPsToMatch) {
		STAssertTrue([anIP isIPAddress], @"%@ should look like an IP address", anIP);
	}
	
	for (NSString *anIP in possibleIPsToNotMatch) {
		STAssertFalse([anIP isIPAddress], @"%@ should not look like an IP address", anIP);
		
	}	
}

- (void)testURLByAddingParameters {
	NSURL *nakedURL = [NSURL URLWithString:@"http://apple.com"];
	NSURL *parameterizedURL = [NSURL URLWithString:@"http://example.com/index.php?a=b&c=d"];
	
	MPURLRequestParameter *aParameter = [[[MPURLRequestParameter alloc] initWithName:@"x" andValue:@"y"] autorelease];
	MPURLRequestParameter *anotherParameter = [[[MPURLRequestParameter alloc] initWithName:@"zeta" andValue:@"beta"] autorelease];
	NSArray *testParameters = [NSArray arrayWithObjects:aParameter, anotherParameter, nil];
	
	STAssertEqualObjects(	[nakedURL urlByAddingParameters:testParameters],
							[NSURL URLWithString:@"http://apple.com?x=y&zeta=beta"],
							@"-urlByAddingParameters failed to correctly add the requested parameters"
						 );
	
	STAssertEqualObjects(	[parameterizedURL urlByAddingParameters:testParameters],
							[NSURL URLWithString:@"http://example.com/index.php?a=b&c=d&x=y&zeta=beta"],
							@"-urlByAddingParameters failed to correctly add the requested parameters"
						 );
	
}

- (void)testURLByAddingParameterDictionary {
	NSURL *nakedURL = [NSURL URLWithString:@"http://apple.com"];
	NSURL *parameterizedURL = [NSURL URLWithString:@"http://example.com/index.php?a=b&c=d"];

	NSDictionary *parameterDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"y", @"x", @"beta", @"zeta", nil];
	NSArray *parameters = [MPURLRequestParameter parametersFromDictionary:parameterDictionary];
	parameters = [parameters sortedArrayUsingSelector:@selector(compare:)];

	// This tests are actually a little bit disingenious but they're a quick sanity check to make sure things are spit out
	// as expected
	STAssertEqualObjects(	[nakedURL urlByAddingParameters:parameters],
							[NSURL URLWithString:@"http://apple.com?x=y&zeta=beta"],
							@"-urlByAddingParameters failed to correctly add the requested parameters"
						 );

	
	STAssertEqualObjects(	[parameterizedURL urlByAddingParameters:parameters],
							[NSURL URLWithString:@"http://example.com/index.php?a=b&c=d&x=y&zeta=beta"],
							@"-urlByAddingParameters failed to correctly add the requested parameters"
						 );
	
}

@end
