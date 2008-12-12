//
//  MPOAuthCredentialConcreteStore.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.11.
//  Copyright 2008 Yahoo. All rights reserved.
//

#import "MPOAuthCredentialConcreteStore.h"
#import "MPURLRequestParameter.h"

@implementation MPOAuthCredentialConcreteStore

- (id)initWithCredentials:(NSDictionary *)inCredentials {
	if (self = [super init]) {
		_store = [[NSMutableDictionary alloc] initWithDictionary:inCredentials];
	}
	return self;
}

- (oneway void)dealloc {
	[_store release];
	
	[super dealloc];
}

- (NSString *)consumerKey {
	return [_store objectForKey:kMPOAuthCredentialConsumerKey];
}

- (NSString *)consumerSecret {
	return [_store objectForKey:kMPOAuthCredentialConsumerSecret];
}

- (NSString *)requestToken {
	return [_store objectForKey:kMPOAuthCredentialRequestToken];
}

- (void)setRequestToken:(NSString *)inToken {
	if (inToken) {
		[_store setObject:inToken forKey:kMPOAuthCredentialRequestToken];
	} else {
		[_store removeObjectForKey:kMPOAuthCredentialRequestToken];
	}
}

- (NSString *)requestTokenSecret {
	return [_store objectForKey:kMPOAuthCredentialRequestTokenSecret];
}

- (void)setRequestTokenSecret:(NSString *)inTokenSecret {
	if (inTokenSecret) {
		[_store setObject:inTokenSecret forKey:kMPOAuthCredentialRequestTokenSecret];
	} else {
		[_store removeObjectForKey:kMPOAuthCredentialRequestTokenSecret];
	}	
}

- (NSString *)accessToken {
	return [_store objectForKey:kMPOAuthCredentialAccessToken];
}

- (void)setAccessToken:(NSString *)inToken {
	if (inToken) {
		[_store setObject:inToken forKey:kMPOAuthCredentialAccessToken];
	} else {
		[_store removeObjectForKey:kMPOAuthCredentialAccessToken];
	}	
}

- (NSString *)accessTokenSecret {
	return [_store objectForKey:kMPOAuthCredentialAccessTokenSecret];
}

- (void)setAccessTokenSecret:(NSString *)inTokenSecret {
	if (inTokenSecret) {
		[_store setObject:inTokenSecret forKey:kMPOAuthCredentialAccessTokenSecret];
	} else {
		[_store removeObjectForKey:kMPOAuthCredentialAccessTokenSecret];
	}	
}

- (NSString *)tokenSecret {
	NSString *tokenSecret = @"";
	
	if (self.accessToken) {
		tokenSecret = [self accessTokenSecret];
	} else if (self.requestToken) {
		tokenSecret = [self requestTokenSecret];
	}
	
	return tokenSecret;
}

- (NSString *)signingKey {
	NSString *consumerSecret = [self consumerSecret];
	NSString *tokenSecret = [self tokenSecret];
	
	return [NSString stringWithFormat:@"%@&%@", consumerSecret, tokenSecret];
}

#pragma mark -

- (NSString *)timestamp {
	return [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
}

- (NSString *)signatureMethod {
	return [_store objectForKey:kMPOAuthSignatureMethod];
}

- (NSArray *)oauthParameters {
	NSMutableArray *oauthParameters = [[NSMutableArray alloc] initWithCapacity:5];	
	MPURLRequestParameter *tokenParameter = [self oauthTokenParameter];
	
	[oauthParameters addObject:[self oauthConsumerKeyParameter]];
	if (tokenParameter) [oauthParameters addObject:tokenParameter];
	[oauthParameters addObject:[self oauthSignatureMethodParameter]];
	[oauthParameters addObject:[self oauthTimestampParameter]];
	[oauthParameters addObject:[self oauthNonceParameter]];
	[oauthParameters addObject:[self oauthVersionParameter]];
	
	return [oauthParameters autorelease];
}

- (void)setSignatureMethod:(NSString *)inSignatureMethod {
	[_store setObject:inSignatureMethod forKey:kMPOAuthSignatureMethod];
}

- (MPURLRequestParameter *)oauthConsumerKeyParameter {
	MPURLRequestParameter *aRequestParameter = [[MPURLRequestParameter alloc] init];
	aRequestParameter.name = @"oauth_consumer_key";
	aRequestParameter.value = self.consumerKey;
	
	return [aRequestParameter autorelease];
}

- (MPURLRequestParameter *)oauthTokenParameter {
	MPURLRequestParameter *aRequestParameter = nil;
	
	if (self.accessToken || self.requestToken) {
		aRequestParameter = [[MPURLRequestParameter alloc] init];
		aRequestParameter.name = @"oauth_token";
		
		if (self.accessToken) {
			aRequestParameter.value = self.accessToken;
		} else if (self.requestToken) {
			aRequestParameter.value = self.requestToken;
		}
	}
	
	return [aRequestParameter autorelease];
}

- (MPURLRequestParameter *)oauthSignatureMethodParameter {
	MPURLRequestParameter *aRequestParameter = [[MPURLRequestParameter alloc] init];
	aRequestParameter.name = @"oauth_signature_method";
	aRequestParameter.value = self.signatureMethod;
	
	return [aRequestParameter autorelease];
}

- (MPURLRequestParameter *)oauthTimestampParameter {
	MPURLRequestParameter *aRequestParameter = [[MPURLRequestParameter alloc] init];
	aRequestParameter.name = @"oauth_timestamp";
	aRequestParameter.value = self.timestamp;
	
	return [aRequestParameter autorelease];
}

- (MPURLRequestParameter *)oauthNonceParameter {
	MPURLRequestParameter *aRequestParameter = [[MPURLRequestParameter alloc] init];
	aRequestParameter.name = @"oauth_nonce";
	
	NSString *generatedNonce = nil;
	CFUUIDRef generatedUUID = CFUUIDCreate(kCFAllocatorDefault);
	generatedNonce = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, generatedUUID);
	CFRelease(generatedUUID);
	
	aRequestParameter.value = generatedNonce;
	
	return [aRequestParameter autorelease];
}

- (MPURLRequestParameter *)oauthVersionParameter {
	MPURLRequestParameter *versionParameter = [_store objectForKey:@"versionParameter"];
	
	if (!versionParameter) {
		versionParameter = [[MPURLRequestParameter alloc] init];
		versionParameter.name = @"oauth_version";
		versionParameter.value = @"1.0";
		[versionParameter autorelease];
	}
	
	return versionParameter;
}

@end
