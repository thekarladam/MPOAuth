//
//  MPOAuthAPI.h
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.05.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPOAuthCredentialStore.h"
#import "MPOAuthParameterFactory.h"

extern NSString *MPOAuthNotificationRequestTokenReceived;
extern NSString *MPOAuthNotificationRequestTokenRejected;
extern NSString *MPOAuthNotificationAccessTokenReceived;
extern NSString *MPOAuthNotificationAccessTokenRejected;
extern NSString *MPOAuthNotificationAccessTokenRefreshed;
extern NSString *MPOAuthNotificationOAuthCredentialsReady;
extern NSString *MPOAuthNotificationErrorHasOccurred;

typedef enum {
	MPOAuthSignatureSchemePlainText,
	MPOAuthSignatureSchemeHMACSHA1,
	MPOAuthSignatureSchemeRSASHA1
} MPOAuthSignatureScheme;

typedef enum {
	MPOAuthAuthenticationStateUnauthenticated		= 0,
	MPOAuthAuthenticationStateRequestRequestToken	= 1,
	MPOAuthAuthenticationStateRequestUserAccess		= 2,
	MPOAuthAuthenticationStateRequestAccessToken	= 3,
	MPOAuthAuthenticationStateAuthenticated			= 4
} MPOAuthAuthenticationState;

@protocol MPOAuthAPIDelegate;

@protocol MPOAuthAPIInternalClient
@end

@class MPOAuthCredentialConcreteStore;

@interface MPOAuthAPI : NSObject <MPOAuthAPIInternalClient> {
	@private
	MPOAuthCredentialConcreteStore	*_credentials;
	NSURL							*_baseURL;
	NSURL							*_authenticationURL;
	NSURL							*_oauthRequestTokenURL;
	NSURL							*_oauthAuthorizeTokenURL;
	NSURL							*_oauthGetAccessTokenURL;
	MPOAuthSignatureScheme			_signatureScheme;
	NSMutableArray					*_activeLoaders;
	id <MPOAuthAPIDelegate>			_delegate;
	NSTimer							*_refreshTimer;
	MPOAuthAuthenticationState		_oauthAuthenticationState;
}

@property (nonatomic, readonly, retain) NSURL *baseURL;
@property (nonatomic, readonly, retain) NSURL *authenticationURL;
@property (nonatomic, readwrite, assign) MPOAuthSignatureScheme signatureScheme;
@property (nonatomic, readwrite, assign) id <MPOAuthAPIDelegate> delegate;

@property (nonatomic, readwrite, retain) NSURL *oauthRequestTokenURL;
@property (nonatomic, readwrite, retain) NSURL *oauthAuthorizeTokenURL;
@property (nonatomic, readwrite, retain) NSURL *oauthGetAccessTokenURL;

@property (nonatomic, readonly, assign) MPOAuthAuthenticationState authenticationState;


- (id)initWithCredentials:(NSDictionary *)inCredentials andBaseURL:(NSURL *)inURL;
- (id)initWithCredentials:(NSDictionary *)inCredentials authenticationURL:(NSURL *)inAuthURL andBaseURL:(NSURL *)inBaseURL;

- (void)authenticate;
- (BOOL)isAuthenticated;

- (void)performMethod:(NSString *)inMethod withTarget:(id)inTarget andAction:(SEL)inAction;
- (void)performMethod:(NSString *)inMethod atURL:(NSURL *)inURL withParameters:(NSArray *)inParameters withTarget:(id)inTarget andAction:(SEL)inAction;

- (NSData *)dataForMethod:(NSString *)inMethod;
- (NSData *)dataForMethod:(NSString *)inMethod withParameters:(NSArray *)inParameters;
- (NSData *)dataForURL:(NSURL *)inURL andMethod:(NSString *)inMethod withParameters:(NSArray *)inParameters;

- (void)discardServerCredentials;

@end


@protocol MPOAuthAPIDelegate <NSObject>
- (NSURL *)callbackURLForCompletedUserAuthorization;
- (BOOL)automaticallyRequestAuthenticationFromURL:(NSURL *)inAuthURL withCallbackURL:(NSURL *)inCallbackURL;
@end
