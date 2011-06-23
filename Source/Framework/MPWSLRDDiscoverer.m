//
//  MPWSLRDDiscoverer.m
//  MPWSConnection
//
//  Created by Karl Adam on 09.03.30.
//  Copyright 2009 matrixPointer. All rights reserved.
//

#import "MPWSLRDDiscoverer.h"

#define kMPWSLRDDiscovererExpectedHTTPHeader @"Link"
#define kMPWSLRDDiscovererExpectedRelType	@"describedby"

@interface MPWSLRDDiscoverer ()
@property (nonatomic, readwrite, retain) NSURL *endpointURL;
@property (nonatomic, readwrite, retain) NSString *soughtType;
@property (nonatomic, readwrite, retain) NSURLConnection *connection;
@property (nonatomic, readwrite, retain) NSURLResponse *response;
@property (nonatomic, readwrite, retain) NSMutableData *responseData;

- (BOOL)_processResponseSearchingForLinkMarkup;
- (BOOL)_processResponseSearchingForLinkHeaders;
- (BOOL)_ignoreResponseAndLookupHostMeta;
- (void)_foundResourceURL:(NSURL *)inURL forType:(NSString *)urlTypeSought;

@end

@implementation MPWSLRDDiscoverer

- (id)init {
	if ((self = [super init])) {
		
	}
	return self;
}

- (oneway void)dealloc {
	self.endpointURL = nil;
	self.soughtType = nil;
	self.connection = nil;
	self.response = nil;
	self.responseData = nil;
	
	[super dealloc];
}

@synthesize delegate = _delegate;
@synthesize endpointURL = _endpointURL;
@synthesize soughtType = _soughtMIMEType;
@synthesize connection = _urlConnection;
@synthesize response = _urlResponse;
@synthesize responseData = _responseData;
@synthesize discoveryState = _discoveryState;

#pragma mark -

- (void)locateResourceOfType:(NSString *)inMimeType fromURL:(NSURL *)inURL {
	self.endpointURL = inURL;
	NSURLRequest *initialPageRequest = [NSURLRequest requestWithURL:inURL];
	NSURLConnection *urlConnection = [NSURLConnection connectionWithRequest:initialPageRequest delegate:self];
	self.connection = urlConnection;
}

- (BOOL)_processResponseSearchingForLinkMarkup {
	BOOL foundMatchingLink = NO;
	//TODO: Determe if type is html derivative and use libxml to derive the link elements from it
	
	return foundMatchingLink;
}

- (BOOL)_processResponseSearchingForLinkHeaders {
	BOOL foundMatchingLink = NO;
	NSDictionary *httpResponseHeaders = [(NSHTTPURLResponse *)self.response allHeaderFields];
	NSString *headerForTitle = [httpResponseHeaders objectForKey:kMPWSLRDDiscovererExpectedHTTPHeader];
	NSScanner *linkScanner = [NSScanner scannerWithString:headerForTitle];
	NSString *foundLink = nil;
	NSString *foundLinkRel = nil;
	NSString *foundLinkType = nil;
	
	while (![linkScanner isAtEnd]) {
		[linkScanner scanUpToString:@"<" intoString:NULL];
		[linkScanner scanUpToString:@">" intoString:&foundLink];
		[linkScanner scanString:@">" intoString:NULL];
		
		[linkScanner scanString:@"; " intoString:NULL];
		[linkScanner scanString:@"rel=\"" intoString:NULL];
		[linkScanner scanUpToString:@"\"" intoString:&foundLinkRel];
		[linkScanner scanString:@"\"" intoString:NULL];
		[linkScanner scanString:@"; " intoString:NULL];
		
		[linkScanner scanString:@"type=\"" intoString:NULL];
		[linkScanner scanUpToString:@"\"" intoString:&foundLinkType];
		[linkScanner scanString:@"\"" intoString:NULL];
		
		if ([foundLinkRel rangeOfString:kMPWSLRDDiscovererExpectedRelType].location != NSNotFound &&
			[foundLinkType isEqualToString:self.soughtType]) {
			NSURL *foundURL = [NSURL URLWithString:foundLink];
			[self _foundResourceURL:foundURL forType:self.soughtType];
			foundMatchingLink = YES;
		}
		
		if (![linkScanner isAtEnd]) {
			[linkScanner scanString:@";" intoString:NULL];
		}
	}
	
	return foundMatchingLink;
}

- (BOOL)_ignoreResponseAndLookupHostMeta {
	BOOL foundMatchingLink = NO;
	//TODO: Parse host-meta link templates
	
	return foundMatchingLink;
}

- (void)_foundResourceURL:(NSURL *)inURL forType:(NSString *)urlTypeSought {
	[self.delegate locatedResourceOfType:urlTypeSought fromURL:self.endpointURL atLocation:inURL];
}
#pragma mark - NSConnection Delegate Methods -

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
	return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	self.responseData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)inConnection didReceiveData:(NSData *)inData {
	[self.responseData appendData:inData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self _processResponseSearchingForLinkMarkup];
}

@end
