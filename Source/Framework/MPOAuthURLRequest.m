//
//  MPOAuthURLRequest.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.05.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import "MPOAuthURLRequest.h"
#import "MPURLRequestParameter.h"
#import "MPOAuthSignatureParameter.h"
#import "NSString+URLEscapingAdditions.h"

@interface MPOAuthURLRequest ()
@property (nonatomic, readwrite, retain) NSURLRequest *urlRequest;
@end

@implementation MPOAuthURLRequest

- (id)initWithURL:(NSURL *)inURL andParameters:(NSArray *)inParameters {
	if (self = [super init]) {
		self.url = inURL;
		_parameters = inParameters ? [inParameters mutableCopy] : [[NSMutableArray alloc] initWithCapacity:10];
		self.HTTPMethod = @"GET";
	}
	return self;
}

- (oneway void)dealloc {
	self.url = nil;
	self.HTTPMethod = nil;
	self.urlRequest = nil;
	self.parameters = nil;
	
	[super dealloc];
}

@synthesize url = _url;
@synthesize HTTPMethod = _httpMethod;
@synthesize urlRequest = _urlRequest;
@synthesize parameters = _parameters;

#pragma mark -

- (NSURLRequest  *)urlRequestSignedWithSecret:(NSString *)inSecret usingMethod:(NSString *)inScheme {
	NSMutableURLRequest *aRequest = [[NSMutableURLRequest alloc] init];
	
	if (@"GET" && [self.parameters count]) {
		[aRequest setHTTPMethod:self.HTTPMethod];
		NSMutableString *queryString = [[NSMutableString alloc] init];
		int i = 0;
		int parameterCount = [self.parameters count];
		
		[self.parameters sortUsingSelector:@selector(compare:)];
		MPURLRequestParameter *aParameter = nil;

		for (; i < parameterCount; i++) {
			aParameter = [self.parameters objectAtIndex:i];
			[queryString appendString:[aParameter HTTPGETParameterString]];

			if (i < parameterCount - 1) {
				[queryString appendString:@"&"];
			}
		}
				
		MPOAuthSignatureParameter *signatureParameter = [[MPOAuthSignatureParameter alloc] initWithText:queryString andSecret:inSecret forRequest:self usingMethod:inScheme];
		NSString *urlString = [NSString stringWithFormat:@"%@?%@&%@", [self.url absoluteString], queryString, [signatureParameter HTTPGETParameterString]];
		NSLog( @"urlString - %@", urlString);
		
		[aRequest setURL:[NSURL URLWithString:urlString]];
		[signatureParameter release];
		[queryString release];
		
	} else if ([[aRequest HTTPMethod] isEqualToString:@"POST"]) {
		
	}
	
	self.urlRequest = aRequest;
		
	return aRequest;
}

#pragma mark -

- (void)addParameters:(NSArray *)inParameters {
	[self.parameters addObjectsFromArray:inParameters];
}

@end
