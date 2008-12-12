//
//  MPOAuthAPIRequestLoader.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.05.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import "MPOAuthAPIRequestLoader.h"
#import "MPOAuthURLRequest.h"
#import "MPOAuthURLResponse.h"
#import "MPOAuthConnection.h"
#import "MPOAuthCredentialStore.h"
#import "MPOAuthCredentialConcreteStore.h"
#import "MPURLRequestParameter.h"
#import "NSURLResponse+Encoding.h"

NSString *MPOAuthNotificationRequestTokenReceived	= @"MPOAuthNotificationRequestTokenReceived";
NSString *MPOAuthNotificationAccessTokenReceived	= @"MPOAuthNotificationAccessTokenReceived";
NSString *MPOAuthNotificationAccessTokenRefreshed	= @"MPOAuthNotificationAccessTokenRefreshed";
NSString *MPOAuthNotificationOAuthCredentialsReady	= @"MPOAuthNotificationOAuthCredentialsReady";
NSString *MPOAuthNotificationErrorHasOccurred		= @"MPOAuthNotificationErrorHasOccurred";

@interface MPOAuthURLResponse ()
@property (nonatomic, readwrite, retain) NSURLResponse *urlResponse;
@property (nonatomic, readwrite, retain) NSDictionary *oauthParameters;
@end


@interface MPOAuthAPIRequestLoader ()
@property (nonatomic, readwrite, retain) NSData *data;
@property (nonatomic, readwrite, retain) NSString *responseString;

- (void)_interrogateResponseForOAuthData;
@end

@protocol MPOAuthAPIInternalClient;

@implementation MPOAuthAPIRequestLoader

- (id)initWithURL:(NSURL *)inURL {
	return [self initWithRequest:[[[MPOAuthURLRequest alloc] initWithURL:inURL andParameters:nil] autorelease]];
}

- (id)initWithRequest:(MPOAuthURLRequest *)inRequest {
	if (self = [super init]) {
		self.oauthRequest = inRequest;
		_dataBuffer = [[NSMutableData alloc] init];
	}
	return self;
}

- (oneway void)dealloc {
	self.credentials = nil;
	self.oauthRequest = nil;
	self.oauthResponse = nil;
	self.data = nil;
	self.responseString = nil;

	[super dealloc];
}

@synthesize credentials = _credentials;
@synthesize oauthRequest = _oauthRequest;
@synthesize oauthResponse = _oauthResponse;
@synthesize data = _dataBuffer;
@synthesize responseString = _dataAsString;
@synthesize target = _target;
@synthesize successSelector = _successSelector;
@synthesize failSelector = _failSelector;

#pragma mark -

- (MPOAuthURLResponse *)oauthResponse {
	if (!_oauthResponse) {
		_oauthResponse = [[MPOAuthURLResponse alloc] init];
	}
	
	return _oauthResponse;
}

- (NSString *)responseString {
	if (!_dataAsString) {
		_dataAsString = [[NSString alloc] initWithData:self.data encoding:[self.oauthResponse.urlResponse encoding]];
	}
	
	return _dataAsString;
}

- (void)loadSynchronously:(BOOL)inSynchronous {
	NSAssert(_credentials, @"Unable to load without valid credentials");
	NSAssert(_credentials.consumerKey, @"Unable to load, credentials contain no consumer key");
	
	if (!inSynchronous) {
		[MPOAuthConnection connectionWithRequest:self.oauthRequest delegate:self credentials:self.credentials];
	} else {
		self.data = [MPOAuthConnection sendSynchronousRequest:self.oauthRequest usingCredentials:self.credentials returningResponse:&_oauthResponse error:nil];
		[self _interrogateResponseForOAuthData];
	}
}

#pragma mark -

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if (_failSelector) {
		[_target performSelector:_failSelector withObject:self withObject:self.data];
	}
	
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"%@", NSStringFromSelector(_cmd));
	
	self.oauthResponse.urlResponse = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSLog(@"%@: data %d bytes", NSStringFromSelector(_cmd), [data length]);
	[_dataBuffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"%@", NSStringFromSelector(_cmd));
	[self _interrogateResponseForOAuthData];
	NSLog(@"Response: %@", self.responseString);
	
	if (_successSelector) {
		if ([_target conformsToProtocol:@protocol(MPOAuthAPIInternalClient)]) {
			[_target performSelector:_successSelector withObject:self withObject:self.data];
		} else {
			[_target performSelector:_successSelector withObject:self.oauthRequest.url withObject:self.responseString];
		}
	}
}

#pragma mark -

- (void)_interrogateResponseForOAuthData {
	NSString *response = self.responseString;
	NSDictionary *foundParameters = nil;
	
	if ([response length] > 5 && [[response substringToIndex:5] isEqualToString:@"oauth"]) {
		foundParameters = [MPURLRequestParameter parameterDictionaryFromString:response];
		self.oauthResponse.oauthParameters = foundParameters;
		
		if ([response length] > 13 && [[response substringToIndex:13] isEqualToString:@"oauth_problem"]) {
			
		} else if ([response length] > 11 && [[response substringToIndex:11] isEqualToString:@"oauth_token"]) {
			NSString *aParameterValue = nil;
			NSLog(@"foundParameters = %@", foundParameters);

			if ([foundParameters count] && (aParameterValue = [foundParameters objectForKey:@"oauth_token"])) {
				if (!self.credentials.requestToken && !self.credentials.accessToken) {
					[_credentials setRequestToken:aParameterValue];
					[_credentials setRequestTokenSecret:[foundParameters objectForKey:@"oauth_token_secret"]];
					
					[[NSNotificationCenter defaultCenter] postNotificationName:MPOAuthNotificationRequestTokenReceived
																		object:nil
																	  userInfo:foundParameters];
					
				} else if (!self.credentials.accessToken && self.credentials.requestToken) {
					[_credentials setRequestToken:nil];
					[_credentials setRequestTokenSecret:nil];
					[_credentials setAccessToken:aParameterValue];
					[_credentials setAccessTokenSecret:[foundParameters objectForKey:@"oauth_token_secret"]];
					
					[[NSNotificationCenter defaultCenter] postNotificationName:MPOAuthNotificationAccessTokenReceived
																		object:nil
																	  userInfo:foundParameters];
					
				} else if (self.credentials.accessToken && !self.credentials.requestToken) {
					// replace the current token
					[_credentials setAccessToken:aParameterValue];
					[_credentials setAccessTokenSecret:[foundParameters objectForKey:@"oauth_token_secret"]];
					
					[[NSNotificationCenter defaultCenter] postNotificationName:MPOAuthNotificationAccessTokenRefreshed
																		object:nil
																	  userInfo:foundParameters];
				}
			}
		}
	}
}

@end
