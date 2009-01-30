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
extern NSString *MPOAuthNotificationAccessTokenReceived;
extern NSString *MPOAuthNotificationAccessTokenRefreshed;
extern NSString *MPOAuthNotificationOAuthCredentialsReady;
extern NSString *MPOAuthNotificationErrorHasOccurred;

typedef enum {
	MPOAuthSignatureSchemePlainText,
	MPOAuthSignatureSchemeHMACSHA1,
	MPOAuthSignatureSchemeRSASHA1
} MPOAuthSignatureScheme;

@protocol MPOAuthAPIDelegate;

@protocol MPOAuthAPIInternalClient
@end

@class MPOAuthCredentialConcreteStore;

@interface MPOAuthAPI : NSObject <MPOAuthAPIInternalClient> {
	@private
	MPOAuthCredentialConcreteStore	*_credentials;
	NSURL							*_baseURL;
	NSURL							*_authenticationURL;
	NSString						*_oauthRequestTokenMethod;
	NSString						*_oauthAuthorizeTokenMethod;
	NSString						*_oauthGetAccessTokenMethod;
	MPOAuthSignatureScheme			_signatureScheme;
	NSMutableArray					*_activeLoaders;
	id <MPOAuthAPIDelegate>			_delegate;
	NSTimer							*_refreshTimer;
}

@property (nonatomic, readonly, retain) NSURL *baseURL;
@property (nonatomic, readonly, retain) NSURL *authenticationURL;
@property (nonatomic, readwrite, assign) MPOAuthSignatureScheme signatureScheme;
@property (nonatomic, readwrite, assign) id <MPOAuthAPIDelegate> delegate;

- (id)initWithCredentials:(NSDictionary *)inCredentials andBaseURL:(NSURL *)inURL;
- (id)initWithCredentials:(NSDictionary *)inCredentials authenticationURL:(NSURL *)inAuthURL andBaseURL:(NSURL *)inBaseURL;

- (void)authenticate;

- (void)performMethod:(NSString *)inMethod withTarget:(id)inTarget andAction:(SEL)inAction;
- (void)performMethod:(NSString *)inMethod atURL:(NSURL *)inURL withParameters:(NSArray *)inParameters withTarget:(id)inTarget andAction:(SEL)inAction;

- (NSData *)dataForMethod:(NSString *)inMethod;
- (NSData *)dataForMethod:(NSString *)inMethod withParameters:(NSArray *)inParameters;
- (NSData *)dataForURL:(NSURL *)inURL andMethod:(NSString *)inMethod withParameters:(NSArray *)inParameters;

@end


@protocol MPOAuthAPIDelegate <NSObject>
- (NSURL *)callbackURLForCompletedUserAuthorization;
- (BOOL)automaticallyRequestAuthenticationFromURL:(NSURL *)inAuthURL withCallbackURL:(NSURL *)inCallbackURL;
@end
