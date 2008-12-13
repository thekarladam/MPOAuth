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

#import "NSURL+MPURLParameterAdditions.h"

NSString *kMPOAuthCredentialConsumerKey			= @"kMPOAuthCredentialConsumerKey";
NSString *kMPOAuthCredentialConsumerSecret		= @"kMPOAuthCredentialConsumerSecret";
NSString *kMPOAuthCredentialRequestToken		= @"kMPOAuthCredentialRequestToken";
NSString *kMPOAuthCredentialRequestTokenSecret	= @"kMPOAuthCredentialRequestTokenSecret";
NSString *kMPOAuthCredentialAccessToken			= @"kMPOAuthCredentialAccessToken";
NSString *kMPOAuthCredentialAccessTokenSecret	= @"kMPOAuthCredentialAccessTokenSecret";

NSString *kMPOAuthSignatureMethod				= @"kMPOAuthSignatureMethod";

@interface MPOAuthAPI ()
@property (nonatomic, readwrite, retain) NSObject <MPOAuthCredentialStore, MPOAuthParameterFactory> *credentials;
@property (nonatomic, readwrite, retain) NSURL *authenticationURL;
@property (nonatomic, readwrite, retain) NSURL *baseURL;
@property (nonatomic, readwrite, retain) NSMutableArray *activeLoaders;

- (void)_authenticationRequestForRequestToken;
- (void)_authenticationRequestForUserPermissionsConfirmationAtURL:(NSURL *)inURL;
- (void)_authenticationRequestForAccessToken;

- (void)addToKeychainUsingName:(NSString *)inName andValue:(NSString *)inValue;
- (NSString *)findValueFromKeychainUsingName:(NSString *)inName;
- (NSString *)findValueFromKeychainUsingName:(NSString *)inName returningItem:(SecKeychainItemRef *)outKeychainItemRef;
- (void)removeValueFromKeychainUsingName:(NSString *)inName;

@end

@implementation MPOAuthAPI

- (id)initWithCredentials:(NSDictionary *)inCredentials andBaseURL:(NSURL *)inBaseURL {
	return [self initWithCredentials:inCredentials authenticationURL:inBaseURL andBaseURL:inBaseURL];
}

- (id)initWithCredentials:(NSDictionary *)inCredentials authenticationURL:(NSURL *)inAuthURL andBaseURL:(NSURL *)inBaseURL {
	if (self = [super init]) {
		NSString *accessToken = [self findValueFromKeychainUsingName:@"oauth_token_access"];
		NSString *accessTokenSecret = [self findValueFromKeychainUsingName:@"oauth_token_access_secret"];
		
		_credentials = [[MPOAuthCredentialConcreteStore alloc] initWithCredentials:inCredentials];
		[(MPOAuthCredentialConcreteStore *)_credentials setAccessToken:accessToken];
		[_credentials setAccessTokenSecret:accessTokenSecret];
		
		self.authenticationURL = inAuthURL;
		self.baseURL = inBaseURL;
		_activeLoaders = [[NSMutableArray alloc] initWithCapacity:10];
		
		self.signatureScheme = MPOAuthSignatureSchemeHMACSHA1;

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_requestTokenReceived:) name:MPOAuthNotificationRequestTokenReceived object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessTokenReceived:) name:MPOAuthNotificationAccessTokenReceived object:nil];		
		
		[self authenticate];
	}
	return self;	
}

- (oneway void)dealloc {
	self.credentials = nil;
	self.baseURL = nil;
	self.authenticationURL = nil;
	self.activeLoaders = nil;
	
	[super dealloc];
}

@synthesize credentials = _credentials;
@synthesize baseURL = _baseURL;
@synthesize authenticationURL = _authenticationURL;
@synthesize signatureScheme = _signatureScheme;
@synthesize activeLoaders = _activeLoaders;
@synthesize delegate = _delegate;

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
	}
}

- (void)_authenticationRequestForRequestToken {
	[self performMethod:@"get_request_token" atURL:self.authenticationURL withParameters:nil withTarget:self andAction:@selector(_authenticationRequestForRequestTokenSuccessfulLoad:withData:)];
}

- (void)_authenticationRequestForRequestTokenSuccessfulLoad:(MPOAuthAPIRequestLoader *)inLoader withData:(NSData *)inData {
	NSDictionary *oauthResponseParameters = inLoader.oauthResponse.oauthParameters;
	NSString *xoauthRequestAuthURL = [oauthResponseParameters objectForKey:@"xoauth_request_auth_url"]; // a common custom extension, used by Yahoo!
	NSURL *userAuthURL = xoauthRequestAuthURL ? [NSURL URLWithString:xoauthRequestAuthURL] : nil;
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
#ifdef TARGET_OS_MAC
	[[NSWorkspace sharedWorkspace] openURL:userAuthURL];
#elif TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
	[[UIApplication sharedApplication] openURL:userAuthURL];
#endif
}

- (void)_authenticationRequestForAccessToken {
	[self performMethod:@"get_token" atURL:self.authenticationURL withParameters:nil withTarget:self andAction:nil];
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
//	loader.failSelector = @selector(_failedLoad:receivingData:);
	
	[loader loadSynchronously:NO];
///	[self.activeLoaders addObject:loader];

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
	NSLog(@"loaded %@, and got %@", inLoader, inData);
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
}

#pragma mark -

- (void)addToKeychainUsingName:(NSString *)inName andValue:(NSString *)inValue {
	NSString *serverName = [_baseURL host];
	NSString *securityDomain = [_authenticationURL host];
	
	SecKeychainAddInternetPassword(NULL /* default keychain */,
								   [serverName length], [serverName UTF8String],
								   [securityDomain length], [securityDomain UTF8String],
								   [inName length], [inName UTF8String],	/* account name */
								   0, NULL,	/* path */
								   0,
								   'oaut'	/* OAuth, not an official OSType code */,
								   kSecAuthenticationTypeDefault,
								   [inValue length], [inValue UTF8String],
								   NULL);
}

- (NSString *)findValueFromKeychainUsingName:(NSString *)inName {
	return [self findValueFromKeychainUsingName:inName returningItem:NULL];
}

- (NSString *)findValueFromKeychainUsingName:(NSString *)inName returningItem:(SecKeychainItemRef *)outKeychainItemRef {
	NSString *foundPassword = nil;
	NSString *serverName = [_baseURL host];
	NSString *securityDomain = [_authenticationURL host];

	UInt32 passwordLength = 0;
	const char *passwordString = NULL;
	
	OSStatus status = SecKeychainFindInternetPassword(NULL	/* default keychain */,
													  [serverName length], [serverName UTF8String],
													  [securityDomain length], [securityDomain UTF8String],
													  [inName length], [inName UTF8String],
													  0, NULL,	/* path */
													  0,
													  (SecProtocolType)NULL,
													  (SecAuthenticationType)NULL,
													  (UInt32 *)&passwordLength,
													  (void **)&passwordString,
													  outKeychainItemRef);
	
	if (status == noErr && passwordLength) {
		NSData *passwordStringData = [NSData dataWithBytes:passwordString length:passwordLength];
		foundPassword = [[NSString alloc] initWithData:passwordStringData encoding:NSUTF8StringEncoding];
	}
	
	return [foundPassword autorelease];
}

- (void)removeValueFromKeychainUsingName:(NSString *)inName {
	SecKeychainItemRef aKeychainItem = NULL;
	
	[self findValueFromKeychainUsingName:inName returningItem:&aKeychainItem];
	
	if (aKeychainItem) {
		SecKeychainItemDelete(aKeychainItem);
	}
}

@end
