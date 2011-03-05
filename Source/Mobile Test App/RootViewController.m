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
#import "MPOAuthAuthenticationMethodOAuth.h"
#import "MPURLRequestParameter.h"

#define kConsumerKey		@"key"
#define kConsumerSecret		@"secret"

@implementation RootViewController

- (void)dealloc {
    [super dealloc];
}

@synthesize methodInput;
@synthesize parametersInput;

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
	[self.navigationItem setPrompt:@"Performing Request Token Request"];
	[self.navigationItem setTitle:@"OAuth Test"];
	[methodInput addTarget:self action:@selector(methodEntered:) forControlEvents:UIControlEventEditingDidEndOnExit];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestTokenReceived:) name:MPOAuthNotificationRequestTokenReceived object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenReceived:) name:MPOAuthNotificationAccessTokenReceived object:nil];
	
}

- (void)viewDidAppear:(BOOL)animated {
	if (!_oauthAPI) {
		NSDictionary *credentials = [NSDictionary dictionaryWithObjectsAndKeys:	kConsumerKey, kMPOAuthCredentialConsumerKey,
									 kConsumerSecret, kMPOAuthCredentialConsumerSecret,
									 nil];
		_oauthAPI = [[MPOAuthAPI alloc] initWithCredentials:credentials
										  authenticationURL:[NSURL URLWithString:@"https://twitter.com/oauth/"]
												 andBaseURL:[NSURL URLWithString:@"https://twitter.com/"]];
		
		if ([[_oauthAPI authenticationMethod] respondsToSelector:@selector(setDelegate:)]) {
			[(MPOAuthAuthenticationMethodOAuth *)[_oauthAPI authenticationMethod] setDelegate:(id <MPOAuthAuthenticationMethodOAuthDelegate>)[UIApplication sharedApplication].delegate];
		}
	} else {
		[_oauthAPI authenticate];
	}
}

- (void)requestTokenReceived:(NSNotification *)inNotification {
	[self.navigationItem setPrompt:@"Awaiting User Authentication"];
}

- (void)accessTokenReceived:(NSNotification *)inNotification {
	[self.navigationItem setPrompt:@"Access Token Received"];
	
	NSData *downloadedData = [_oauthAPI dataForMethod:@"/statuses/friends_timeline.xml"];
	NSLog(@"downloadedData of size - %d", [downloadedData length]);
}

- (void)errorOccurred:(NSNotification *)inNotification {
	[self.navigationItem setPrompt:@"Error Occurred"];
	textOutput.text = [[inNotification userInfo] objectForKey:@"oauth_problem"];
}

- (void)_methodLoadedFromURL:(NSURL *)inURL withResponseString:(NSString *)inString {
	textOutput.text = inString;
}

- (void)methodEntered:(UITextField *)aTextField {
	NSString *method = methodInput.text;
	NSString *paramsString = parametersInput.text;
	
	NSArray *params = nil;
	if (paramsString.length > 0) {
		params = [MPURLRequestParameter parametersFromString:paramsString];
	}
	
	[_oauthAPI performMethod:method atURL:_oauthAPI.baseURL withParameters:params withTarget:self andAction:@selector(_methodLoadedFromURL:withResponseString:)];
}

- (void)clearCredentials {
	[self.navigationItem setPrompt:@"Credentials Cleared"];
	textOutput.text = @"";
	[_oauthAPI discardCredentials];
}

- (void)reauthenticate {
	[self.navigationItem setPrompt:@"Reauthenticating User"];
	textOutput.text = @"";
	[_oauthAPI authenticate];	
}

@end

