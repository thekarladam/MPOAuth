//
//  MPOAuthAPI.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.05.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import "MPOAuthAPIRequestLoader.h"
#import "MPOAuthAPI.h"
#import "MPOAuthCredentialConcreteStore.h"
#import "MPOAuthURLRequest.h"
#import "MPOAuthURLResponse.h"
#import "MPURLRequestParameter.h"

#import "NSURL+MPURLParameterAdditions.h"
#import "MPOAuthAPI+KeychainAdditions.h"

#define kMPOAuthTokenRefreshDateDefaultsKey		@"MPOAuthAutomaticTokenRefreshLastExpiryDate"

NSString *kMPOAuthCredentialConsumerKey			= @"kMPOAuthCredentialConsumerKey";
NSString *kMPOAuthCredentialConsumerSecret		= @"kMPOAuthCredentialConsumerSecret";
NSString *kMPOAuthCredentialRequestToken		= @"kMPOAuthCredentialRequestToken";
NSString *kMPOAuthCredentialRequestTokenSecret	= @"kMPOAuthCredentialRequestTokenSecret";
NSString *kMPOAuthCredentialAccessToken			= @"kMPOAuthCredentialAccessToken";
NSString *kMPOAuthCredentialAccessTokenSecret	= @"kMPOAuthCredentialAccessTokenSecret";
NSString *kMPOAuthCredentialSessionHandle		= @"kMPOAuthCredentialSessionHandle";

NSString *kMPOAuthSignatureMethod				= @"kMPOAuthSignatureMethod";

@interface MPOAuthAPI ()
@property (nonatomic, readwrite, retain) NSObject <MPOAuthCredentialStore, MPOAuthParameterFactory> *credentials;
@property (nonatomic, readwrite, retain) NSURL *authenticationURL;
@property (nonatomic, readwrite, retain) NSURL *baseURL;
@property (nonatomic, readwrite, retain) NSString *oauthRequestTokenMethod;
@property (nonatomic, readwrite, retain) NSString *oauthAuthorizeTokenMethod;
@property (nonatomic, readwrite, retain) NSString *oauthGetAccessTokenMethod;

@property (nonatomic, readwrite, retain) NSMutableArray *activeLoaders;
@property (nonatomic, readwrite, retain) NSTimer *refreshTimer;

- (void)_initAuthorizationEndpointsForURL:(NSURL *)inBaseURL;
- (void)_authenticationRequestForRequestToken;
- (void)_authenticationRequestForUserPermissionsConfirmationAtURL:(NSURL *)inURL;
- (void)_authenticationRequestForAccessToken;
- (void)_automaticallyRefreshAccessToken:(NSTimer *)inTimer;

@end

@implementation MPOAuthAPI

- (id)initWithCredentials:(NSDictionary *)inCredentials andBaseURL:(NSURL *)inBaseURL {
	return [self initWithCredentials:inCredentials authenticationURL:inBaseURL andBaseURL:inBaseURL];
}

- (id)initWithCredentials:(NSDictionary *)inCredentials authenticationURL:(NSURL *)inAuthURL andBaseURL:(NSURL *)inBaseURL {
	if (self = [super init]) {
		self.authenticationURL = inAuthURL;
		self.baseURL = inBaseURL;

		// load authorization endpoints from file
		[self _initAuthorizationEndpointsForURL:inAuthURL];
		
		NSString *requestToken = [self findValueFromKeychainUsingName:@"oauth_token_request"];
		NSString *requestTokenSecret = [self findValueFromKeychainUsingName:@"oauth_token_request_secret"];
		NSString *accessToken = [self findValueFromKeychainUsingName:@"oauth_token_access"];
		NSString *accessTokenSecret = [self findValueFromKeychainUsingName:@"oauth_token_access_secret"];
		NSString *sessionHandle = [self findValueFromKeychainUsingName:@"oauth_session_handle"];
		
		_credentials = [[MPOAuthCredentialConcreteStore alloc] initWithCredentials:inCredentials];
		[_credentials setRequestToken:requestToken];
		[_credentials setRequestTokenSecret:requestTokenSecret];
		[(MPOAuthCredentialConcreteStore *)_credentials setAccessToken:accessToken];
		[_credentials setAccessTokenSecret:accessTokenSecret];
		[_credentials setSessionHandle:sessionHandle];
		
		_activeLoaders = [[NSMutableArray alloc] initWithCapacity:10];
		
		self.signatureScheme = MPOAuthSignatureSchemeHMACSHA1;

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_requestTokenReceived:) name:MPOAuthNotificationRequestTokenReceived object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessTokenReceived:) name:MPOAuthNotificationAccessTokenReceived object:nil];		
		
		[self authenticate];
	}
	return self;	
}

- (void)_initAuthorizationEndpointsForURL:(NSURL *)inBaseURL {
	NSString *oauthEndpointsConfigPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"oauthAutoConfig" ofType:@"plist"];
	NSDictionary *oauthEndpointsDictionary = [NSDictionary dictionaryWithContentsOfFile:oauthEndpointsConfigPath];
	
	for ( NSString *domainString in [oauthEndpointsDictionary keyEnumerator]) {
		if ([inBaseURL domainMatches:domainString]) {
			NSArray *oauthEndpoints = [oauthEndpointsDictionary objectForKey:domainString];
			NSAssert( [oauthEndpoints count] == 3, @"Incorrect number of oauth authorization methods");
			
			self.oauthRequestTokenMethod = [oauthEndpoints objectAtIndex:0];
			self.oauthAuthorizeTokenMethod = [oauthEndpoints objectAtIndex:1];
			self.oauthGetAccessTokenMethod = [oauthEndpoints objectAtIndex:2];

			break;
		}
	}
}

- (oneway void)dealloc {
	self.credentials = nil;
	self.baseURL = nil;
	self.authenticationURL = nil;
	self.activeLoaders = nil;
	
	[self.refreshTimer invalidate];
	self.refreshTimer = nil;
	
	[super dealloc];
}

@synthesize credentials = _credentials;
@synthesize baseURL = _baseURL;
@synthesize authenticationURL = _authenticationURL;
@synthesize oauthRequestTokenMethod = _oauthRequestTokenMethod;
@synthesize oauthAuthorizeTokenMethod = _oauthAuthorizeTokenMethod;
@synthesize oauthGetAccessTokenMethod = _oauthGetAccessTokenMethod;
@synthesize signatureScheme = _signatureScheme;
@synthesize activeLoaders = _activeLoaders;
@synthesize delegate = _delegate;
@synthesize refreshTimer = _refreshTimer;

#pragma mark -

- (void)setSignatureScheme:(MPOAuthSignatureScheme)inScheme {
	_signatureScheme = inScheme;
	
	NSString *methodString = @"HMAC-SHA1";
	
	switch (_signatureScheme) {
		case MPOAuthSignatureSchemePlainText:
			methodString = @"PLAINTEXT";
			break;
		case MPOAuthSignatureSchemeRSASHA1:
			methodString = @"RSA-SHA1";
		case MPOAuthSignatureSchemeHMACSHA1:
		default:
			// already initted to the default
			break;
	}
	
	_credentials.signatureMethod = methodString;
}

#pragma mark -

- (void)authenticate {
	NSAssert(_credentials.consumerKey, @"A Consumer Key is required for use of OAuth.");
	
	if (!_credentials.accessToken && !_credentials.requestToken) {
		[self _authenticationRequestForRequestToken];
	} else if (!_credentials.accessToken) {
		[self _authenticationRequestForAccessToken];
	} else if (_credentials.accessToken) {
		NSTimeInterval expiryDateInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:kMPOAuthTokenRefreshDateDefaultsKey];
		NSDate *tokenExpiryDate = [NSDate dateWithTimeIntervalSinceReferenceDate:expiryDateInterval];
		
		if ([tokenExpiryDate compare:[NSDate date]] == NSOrderedAscending) {
			[self _automaticallyRefreshAccessToken:nil];
		}
	}
}

- (void)_authenticationRequestForRequestToken {
	[self performMethod:self.oauthRequestTokenMethod atURL:self.authenticationURL withParameters:nil withTarget:self andAction:@selector(_authenticationRequestForRequestTokenSuccessfulLoad:withData:)];
}

- (void)_authenticationRequestForRequestTokenSuccessfulLoad:(MPOAuthAPIRequestLoader *)inLoader withData:(NSData *)inData {
	NSDictionary *oauthResponseParameters = inLoader.oauthResponse.oauthParameters;
	NSString *xoauthRequestAuthURL = [oauthResponseParameters objectForKey:@"xoauth_request_auth_url"]; // a common custom extension, used by Yahoo!
	NSURL *userAuthURL = xoauthRequestAuthURL ? [NSURL URLWithString:xoauthRequestAuthURL] : [NSURL URLWithString:self.oauthAuthorizeTokenMethod relativeToURL:self.authenticationURL];
	NSURL *callbackURL = [self.delegate respondsToSelector:@selector(callbackURLForCompletedUserAuthorization)] ? [self.delegate callbackURLForCompletedUserAuthorization] : nil;
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:	[oauthResponseParameters objectForKey:@"oauth_token"], @"oauth_token",
																			callbackURL, @"oauth_callback",
																			nil];

	userAuthURL = [userAuthURL urlByAddingParameterDictionary:parameters];
	BOOL delegateWantsToBeInvolved = [self.delegate respondsToSelector:@selector(automaticallyRequestAuthenticationFromURL:withCallbackURL:)];

	if (!delegateWantsToBeInvolved || (delegateWantsToBeInvolved && [self.delegate automaticallyRequestAuthenticationFromURL:userAuthURL withCallbackURL:callbackURL])) {
		[self _authenticationRequestForUserPermissionsConfirmationAtURL:userAuthURL];
	}
}

- (void)_authenticationRequestForUserPermissionsConfirmationAtURL:(NSURL *)userAuthURL {
#ifndef TARGET_OS_IPHONE
	[[NSWorkspace sharedWorkspace] openURL:userAuthURL];
#else
	[[UIApplication sharedApplication] openURL:userAuthURL];
#endif
}

- (void)_authenticationRequestForAccessToken {
	[self performMethod:self.oauthGetAccessTokenMethod atURL:self.authenticationURL withParameters:nil withTarget:self andAction:nil];
}

#pragma mark -

- (void)performMethod:(NSString *)inMethod withTarget:(id)inTarget andAction:(SEL)inAction {
	[self performMethod:inMethod atURL:self.baseURL withParameters:nil withTarget:inTarget andAction:inAction];
}

- (void)performMethod:(NSString *)inMethod atURL:(NSURL *)inURL withParameters:(NSArray *)inParameters withTarget:(id)inTarget andAction:(SEL)inAction {
	NSURL *requestURL = [NSURL URLWithString:inMethod relativeToURL:inURL];
	MPOAuthURLRequest *aRequest = [[MPOAuthURLRequest alloc] initWithURL:requestURL andParameters:inParameters];
	MPOAuthAPIRequestLoader *loader = [[MPOAuthAPIRequestLoader alloc] initWithRequest:aRequest];

	loader.credentials = self.credentials;
	loader.target = inTarget;
	loader.successSelector = inAction ? inAction : @selector(_performedLoad:receivingData:);
	
	[loader loadSynchronously:NO];
//	[self.activeLoaders addObject:loader];

	[loader release];
	[aRequest release];
}

- (NSData *)dataForMethod:(NSString *)inMethod {
	return [self dataForURL:self.baseURL andMethod:inMethod withParameters:nil];
}

- (NSData *)dataForMethod:(NSString *)inMethod withParameters:(NSArray *)inParameters {
	return [self dataForURL:self.baseURL andMethod:inMethod withParameters:inParameters];
}

- (NSData *)dataForURL:(NSURL *)inURL andMethod:(NSString *)inMethod withParameters:(NSArray *)inParameters {
	NSURL *requestURL = [NSURL URLWithString:inMethod relativeToURL:inURL];
	MPOAuthURLRequest *aRequest = [[MPOAuthURLRequest alloc] initWithURL:requestURL andParameters:inParameters];
	MPOAuthAPIRequestLoader *loader = [[MPOAuthAPIRequestLoader alloc] initWithRequest:aRequest];

	loader.credentials = self.credentials;
	[loader loadSynchronously:YES];
	
	[loader autorelease];
	[aRequest release];
	
	return loader.data;
}

#pragma mark -

- (void)_performedLoad:(MPOAuthAPIRequestLoader *)inLoader receivingData:(NSData *)inData {
//	NSLog(@"loaded %@, and got %@", inLoader, inData);
}

#pragma mark -

- (void)_requestTokenReceived:(NSNotification *)inNotification {
	[self addToKeychainUsingName:@"oauth_token_request" andValue:[[inNotification userInfo] objectForKey:@"oauth_token"]];
	[self addToKeychainUsingName:@"oauth_token_request_secret" andValue:[[inNotification userInfo] objectForKey:@"oauth_token_secret"]];
}

- (void)_accessTokenReceived:(NSNotification *)inNotification {
	[self removeValueFromKeychainUsingName:@"oauth_token_request"];
	[self removeValueFromKeychainUsingName:@"oauth_token_request_secret"];
	
	[self addToKeychainUsingName:@"oauth_token_access" andValue:[[inNotification userInfo] objectForKey:@"oauth_token"]];
	[self addToKeychainUsingName:@"oauth_token_access_secret" andValue:[[inNotification userInfo] objectForKey:@"oauth_token_secret"]];
	
	[self addToKeychainUsingName:@"oauth_session_handle" andValue:[[inNotification userInfo] objectForKey:@"oauth_session_handle"]];
	
	NSTimeInterval tokenRefreshInterval = (NSTimeInterval)[[[inNotification userInfo] objectForKey:@"oauth_expires_in"] intValue];
	NSDate *tokenExpiryDate = [NSDate dateWithTimeIntervalSinceNow:tokenRefreshInterval];
	[[NSUserDefaults standardUserDefaults] setDouble:[tokenExpiryDate timeIntervalSinceReferenceDate] forKey:kMPOAuthTokenRefreshDateDefaultsKey];
	
	if (!_refreshTimer && tokenRefreshInterval > 0.0) {
		self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:tokenRefreshInterval target:self selector:@selector(_automaticallyRefreshAccessToken:) userInfo:nil repeats:YES];
	}
}

#pragma mark -

- (void)_automaticallyRefreshAccessToken:(NSTimer *)inTimer {
	MPURLRequestParameter *sessionHandleParameter = [[MPURLRequestParameter alloc] init];
	sessionHandleParameter.name = @"oauth_session_handle";
	sessionHandleParameter.value = _credentials.sessionHandle;
	
	[self performMethod:self.oauthGetAccessTokenMethod
				  atURL:self.authenticationURL
		 withParameters:[NSArray arrayWithObject:sessionHandleParameter]
			 withTarget:self
			  andAction:@selector(_authenticationRequestForRequestTokenSuccessfulLoad:withData:)];
	
	[sessionHandleParameter release];
}

@end
