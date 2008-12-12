//
//  MPOAuthCredentialConcreteStore.h
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.11.
//  Copyright 2008 Yahoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPOAuthCredentialStore.h"
#import "MPOAuthParameterFactory.h"

@interface MPOAuthCredentialConcreteStore : NSObject <MPOAuthCredentialStore, MPOAuthParameterFactory> {
	NSMutableDictionary *_store;
}

@property (nonatomic, readonly) NSString *tokenSecret;
@property (nonatomic, readonly) NSString *signingKey;

@property (nonatomic, readwrite, retain) NSString *requestToken;
@property (nonatomic, readwrite, retain) NSString *requestTokenSecret;
@property (nonatomic, readwrite, retain) NSString *accessToken;
@property (nonatomic, readwrite, retain) NSString *accessTokenSecret;

- (id)initWithCredentials:(NSDictionary *)inCredentials;

@end
