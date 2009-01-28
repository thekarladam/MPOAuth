//
//  RootViewController.m
//  MPOAuthMobile
//
//  Created by Karl Adam on 08.12.14.
//  Copyright matrixPointer 2008. All rights reserved.
//

#import "RootViewController.h"
#import "MPOAuthMobileAppDelegate.h"
#import "MPOAuthAPI.h"

#define kConsumerKey		@"key"
#define kConsumerSecret		@"secret"


@implementation RootViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.navigationItem setPrompt:@"Performing Request Token Request"];
	[self.navigationItem setTitle:@"OAuth Test"];
	[methodInput addTarget:self action:@selector(methodEntered:) forControlEvents:UIControlEventEditingDidEndOnExit];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestTokenReceived:) name:MPOAuthNotificationRequestTokenReceived object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenReceived:) name:MPOAuthNotificationAccessTokenReceived object:nil];
	
	NSDictionary *credentials = [NSDictionary dictionaryWithObjectsAndKeys:	kConsumerKey, kMPOAuthCredentialConsumerKey,
																			kConsumerSecret, kMPOAuthCredentialConsumerSecret,
								 nil];
	_oauthAPI = [[MPOAuthAPI alloc] initWithCredentials:credentials
									  authenticationURL:[NSURL URLWithString:@"https://example.com/oauth/"]
											 andBaseURL:[NSURL URLWithString:@"http://example.com/webservice/"]];
	
}

- (void)dealloc {
    [super dealloc];
}

- (void)requestTokenReceived:(NSNotification *)inNotification {
	[self.navigationItem setPrompt:@"Awaiting User Authentication"];
}

- (void)accessTokenReceived:(NSNotification *)inNotification {
	[self.navigationItem setPrompt:@"Access Token Received"];
}

- (void)_methodLoadedFromURL:(NSURL *)inURL withResponseString:(NSString *)inString {
	textOutput.text = inString;
}

- (void)methodEntered:(UITextField *)inTextField {
	[_oauthAPI performMethod:inTextField.text withTarget:self andAction:@selector(_methodLoadedFromURL:withResponseString:)];
}

@end

