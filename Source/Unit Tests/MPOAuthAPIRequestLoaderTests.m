//
//  MPOAuthAPIRequestLoaderTests.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.18.
//  Copyright 2008 matrixPointer. All rights reserved.
//

// Adapted entirely from Jon Crosby's OAuthConsumer Test Suite OADataFetcherTest

#import "MPOAuthAPIRequestLoaderTests.h"
#import "MPOAuthCredentialConcreteStore.h"
#import "MPOAuthAPI.h"
#import "MPOAuthAPIRequestLoader.h"
#import "MPOAuthURLRequest.h"

@implementation MPOAuthAPIRequestLoaderTests

- (void)setUp {
	NSString *currentDir = [[NSFileManager defaultManager] currentDirectoryPath];
    NSString *serverPath = [currentDir stringByAppendingPathComponent:@"Source/Unit Tests/OATestServer.rb"];
    
    server = [[NSTask alloc] init];
    [server setArguments:[NSArray arrayWithObject:serverPath]];
    [server setLaunchPath:@"/usr/bin/ruby"];
    [server launch];
    sleep(2); // let the server get ready to respond
	
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenReceived:) name:MPOAuthNotificationAccessTokenReceived object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestTokenReceived:) name:MPOAuthNotificationRequestTokenReceived object:nil];
}

- (void)tearDown {
    [server terminate];
}

- (void)testFetchData {
	NSDictionary *credentials = [NSDictionary dictionaryWithObjectsAndKeys:	@"dpf43f3p2l4k3l03", kMPOAuthCredentialConsumerKey,
																			@"kd94hf93k423kf44", kMPOAuthCredentialConsumerSecret,
								 nil];
	NSURL *url = [NSURL URLWithString:@"http://localhost:4567/request_token"];
	MPOAuthCredentialConcreteStore *credentialStore = [[MPOAuthCredentialConcreteStore alloc] initWithCredentials:credentials forBaseURL:url withAuthenticationURL:url];
	credentialStore.signatureMethod = @"PLAINTEXT";
	
	MPOAuthURLRequest *urlRequest = [[MPOAuthURLRequest alloc] initWithURL:url andParameters:nil];
	[urlRequest setHTTPMethod:@"POST"];
	MPOAuthAPIRequestLoader *requestLoader = [[MPOAuthAPIRequestLoader alloc] initWithRequest:urlRequest];
	requestLoader.credentials = credentialStore;
	[requestLoader loadSynchronously:YES];
}

- (void)requestTokenReceived:(NSNotification *)inNotification {
	NSString *token = [[inNotification userInfo] objectForKey:@"oauth_token"];
	NSString *tokenSecret = [[inNotification userInfo] objectForKey:@"oauth_token_secret"];
	
	STAssertEqualObjects(token, @"nnch734d00sl2jdk", @"Expected Token Not Found");
    STAssertEqualObjects(tokenSecret, @"pfkkdhi9sl3r4s00", @"Expected Token Secret Not Found");
}

//- (void)accessTokenReceived:(NSNotification *)inNotification {
//	
//}

@end
