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

#import "NSURL+MPURLParameterAdditions.h"
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

- (id)initWithURLRequest:(NSURLRequest *)inRequest {
	if (self = [super init]) {
		self.url = [[inRequest URL] urlByRemovingQuery];
		self.parameters = [[MPURLRequestParameter parametersFromString:[[inRequest URL] query]] mutableCopy];
		self.HTTPMethod = [inRequest HTTPMethod];
		self.urlRequest = [[inRequest mutableCopy] autorelease];
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
- (NSString *)buildAuthString:(NSString*)parameterString {
	NSDictionary *paramsDict = [MPURLRequestParameter parameterDictionaryFromString:parameterString];
	NSString *signature = [[paramsDict objectForKey:@"oauth_signature"] stringByAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *nonce = [[paramsDict objectForKey:@"oauth_nonce"] stringByAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *token = [[paramsDict objectForKey:@"oauth_token"] stringByAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *consumerKey = [[paramsDict objectForKey:@"oauth_consumer_key"] stringByAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *timeStamp = [[paramsDict objectForKey:@"oauth_timestamp"] stringByAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *version = [[paramsDict objectForKey:@"oauth_version"] stringByAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *method = [[paramsDict objectForKey:@"oauth_signature_method"] stringByAddingURIPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *fullAuthString = [NSString stringWithFormat:@"OAuth oauth_token=\"%@\",oauth_consumer_key=\"%@\",oauth_version=\"%@\",oauth_signature_method=\"%@\", oauth_timestamp=\"%@\",oauth_nonce=\"%@\",oauth_signature=\"%@\"",token,consumerKey, version, method,timeStamp, nonce,signature];

	return [fullAuthString autorelease];
}

- (NSURLRequest  *)urlRequestSignedWithSecret:(NSString *)inSecret usingMethod:(NSString *)inScheme {
	NSMutableURLRequest *aRequest = [self.urlRequest mutableCopy];
	[self.parameters sortUsingSelector:@selector(compare:)];

	if (!aRequest ) {
		aRequest = [[NSMutableURLRequest alloc] init];
	}
	
	NSMutableString *parameterString = [[NSMutableString alloc] initWithString:[MPURLRequestParameter parameterStringForParameters:self.parameters]];
	MPOAuthSignatureParameter *signatureParameter = [[MPOAuthSignatureParameter alloc] initWithText:parameterString andSecret:inSecret forRequest:self usingMethod:inScheme];
	[parameterString appendFormat:@"&%@", [signatureParameter URLEncodedParameterString]];
	
	[aRequest setHTTPMethod:self.HTTPMethod];
	
	NSString *urlString = nil;
	if ([[self HTTPMethod] isEqualToString:@"GET"] && [self.parameters count]) {
		urlString = [NSString stringWithFormat:@"%@?%@", [self.url absoluteString], parameterString];
		MPLog( @"urlString - %@", urlString);
	}else if  ([[self HTTPMethod] isEqualToString:@"POST"] && [self.parameters count]){
		[aRequest setValue: [self buildAuthString:parameterString] forHTTPHeaderField:@"Authorization"];
		urlString =  [self.url absoluteString];
		MPLog( @"urlString - %@", urlString);
		
	}else {
		[NSException raise:@"UnhandledHTTPMethodException" format:@"The requested HTTP method, %@, is not supported", self.HTTPMethod];
	}
	
	[aRequest setURL:[NSURL URLWithString:urlString]];
	
	[parameterString release];
	[signatureParameter release];		
	
	self.urlRequest = aRequest;
	[aRequest release];
	
	return aRequest;
}

#pragma mark -

- (void)addParameters:(NSArray *)inParameters {
	[self.parameters addObjectsFromArray:inParameters];
}

@end
