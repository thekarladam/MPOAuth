//
//  MPOAuthAuthenticationMethodXAuth.m
//  MPOAuth
//
//  Created by Karl Adam on 10.03.07.
//  Copyright 2010 matrixPointer. All rights reserved.
//

#import "MPOAuthAuthenticationMethodXAuth.h"
#import "MPURLRequestParameter.h"
#import "MPOAuthAPIRequestLoader.h"

@interface MPOAuthAPI ()
@property (nonatomic, readwrite, assign) MPOAuthAuthenticationState authenticationState;
@end

@implementation MPOAuthAuthenticationMethodXAuth

- (id)initWithAPI:(MPOAuthAPI *)inAPI forURL:(NSURL *)inURL withConfiguration:(NSDictionary *)inConfig {
	if ((self = [super initWithAPI:inAPI forURL:inURL withConfiguration:inConfig])) {
		self.oauthGetAccessTokenURL = [NSURL URLWithString:[inConfig objectForKey:MPOAuthAccessTokenURLKey]];
	}
	return self;
}

- (void)authenticate {
	id <MPOAuthCredentialStore> credentials = [self.oauthAPI credentials];
	
	if (!credentials.accessToken && !credentials.accessTokenSecret) {
		MPLog(@"--> Performing Access Token Request: %@", self.oauthGetAccessTokenURL);
		NSString *username = [[self.oauthAPI credentials] username];
		NSString *password = [[self.oauthAPI credentials] password];
		NSAssert(username, @"XAuth requires a Username credential");
		NSAssert(password, @"XAuth requires a Password credential");
		
		MPURLRequestParameter *usernameParameter = [[MPURLRequestParameter alloc] initWithName:@"x_auth_username" andValue:username];
		MPURLRequestParameter *passwordParameter = [[MPURLRequestParameter alloc] initWithName:@"x_auth_password" andValue:password];
		MPURLRequestParameter *clientModeParameter = [[MPURLRequestParameter alloc] initWithName:@"x_auth_mode" andValue:@"client_auth"];
		
		[self.oauthAPI performPOSTMethod:nil
								   atURL:self.oauthGetAccessTokenURL
						  withParameters:[NSArray arrayWithObjects:usernameParameter, passwordParameter, clientModeParameter, nil]
							  withTarget:self
							   andAction:nil];
	} else if (credentials.accessToken && credentials.accessTokenSecret) {
		NSTimeInterval expiryDateInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:MPOAuthTokenRefreshDateDefaultsKey];
		NSDate *tokenExpiryDate = [NSDate dateWithTimeIntervalSinceReferenceDate:expiryDateInterval];
		
		if ([tokenExpiryDate compare:[NSDate date]] == NSOrderedAscending) {
			[self refreshAccessToken];
		}
	}	
	
}

- (void)_performedLoad:(MPOAuthAPIRequestLoader *)inLoader receivingData:(NSData *)inData {
	MPLog(@"loaded %@, and got:\n %@", inLoader, inData);
	NSString *responseString = [inLoader responseString];
	NSDictionary *responseParameters = [MPURLRequestParameter parameterDictionaryFromString:responseString];
	MPLog(@"responseParameters = %@", responseParameters);
	NSString *accessToken = [responseParameters objectForKey:@"oauth_token"];
	NSString *accessTokenSecret = [responseParameters objectForKey:@"oauth_token_secret"];
	
	
	if (accessToken && accessTokenSecret) {
		[self.oauthAPI removeCredentialNamed:kMPOAuthCredentialPassword];
		[self.oauthAPI setCredential:accessToken withName:kMPOAuthCredentialAccessToken];
		[self.oauthAPI setCredential:accessTokenSecret withName:kMPOAuthCredentialAccessTokenSecret];
	}
	
	[self.oauthAPI setAuthenticationState:MPOAuthAuthenticationStateAuthenticated];
	
}

@end
