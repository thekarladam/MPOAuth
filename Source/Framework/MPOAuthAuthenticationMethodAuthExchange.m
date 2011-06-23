//
//  MPOAuthAuthenticationMethodAuthExchange.m
//  MPOAuthMobile
//
//  Created by Karl Adam on 09.12.20.
//  Copyright 2009 matrixPointer. All rights reserved.
//

#import "MPOAuthAuthenticationMethodAuthExchange.h"
#import "MPOAuthAPI.h"
#import "MPOAuthAPIRequestLoader.h"
#import "MPOAuthCredentialStore.h"
#import "MPURLRequestParameter.h"

#import <libxml/parser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

@interface MPOAuthAPI ()
@property (nonatomic, readwrite, assign) MPOAuthAuthenticationState authenticationState;
@end

@implementation MPOAuthAuthenticationMethodAuthExchange

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
		NSAssert(username, @"AuthExchange requires a Username credential");
		NSAssert(password, @"AuthExchange requires a Password credential");
		
		MPURLRequestParameter *usernameParameter = [[MPURLRequestParameter alloc] initWithName:@"fs_username" andValue:username];
		MPURLRequestParameter *passwordParameter = [[MPURLRequestParameter alloc] initWithName:@"fs_password" andValue:password];
		
		[self.oauthAPI performPOSTMethod:nil
								   atURL:self.oauthGetAccessTokenURL
						  withParameters:[NSArray arrayWithObjects:usernameParameter, passwordParameter, nil]
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
	NSString *accessToken = nil;
	NSString *accessTokenSecret = nil;
	const char *xmlCString = (const char *)[inData bytes];
	xmlParserCtxtPtr parserContext = xmlNewParserCtxt();
	xmlDocPtr accessTokenXML = xmlCtxtReadMemory(parserContext, xmlCString, strlen(xmlCString), NULL, NULL, XML_PARSE_NOBLANKS);
	xmlNodePtr rootNode = xmlDocGetRootElement(accessTokenXML);
	xmlNodePtr currentNode = rootNode->children;
	const char *currentNodeName = NULL;
	
	for ( ; currentNode; currentNode = currentNode->next) {
		currentNodeName = (const char *)currentNode->name;
		
		if (strcmp("oauth_token", currentNodeName) == 0) {
			xmlChar *oauthToken = xmlNodeGetContent(currentNode);
			accessToken = [NSString stringWithUTF8String:(const char *)oauthToken];
		} else if (strcmp("oauth_token_secret", currentNodeName) == 0) {
			xmlChar *oauthTokenSecret = xmlNodeGetContent(currentNode);
			accessTokenSecret = [NSString stringWithUTF8String:(const char *)oauthTokenSecret];
		}
	}
	
	if (accessToken && accessTokenSecret) {
		[self.oauthAPI removeCredentialNamed:kMPOAuthCredentialPassword];
		[self.oauthAPI setCredential:accessToken withName:kMPOAuthCredentialAccessToken];
		[self.oauthAPI setCredential:accessTokenSecret withName:kMPOAuthCredentialAccessTokenSecret];
	}
	
	[self.oauthAPI setAuthenticationState:MPOAuthAuthenticationStateAuthenticated];
	
	xmlFreeDoc(accessTokenXML);
	xmlFreeParserCtxt(parserContext);
}

@end
