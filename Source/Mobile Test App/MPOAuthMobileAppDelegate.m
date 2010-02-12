//
//  MPOAuthMobileAppDelegate.m
//  MPOAuthMobile
//
//  Created by Karl Adam on 08.12.14.
//  Copyright matrixPointer 2008. All rights reserved.
//

#import "MPOAuthAuthenticationMethodOAuth.h"
#import "MPOAuthMobileAppDelegate.h"
#import "RootViewController.h"

#import "MPURLRequestParameter.h"

@implementation MPOAuthMobileAppDelegate

@synthesize window = window_;
@synthesize navigationController = navigationController_;
@synthesize oauthVerifier = oauthVerifier_;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// Configure and show the window
	[window_ addSubview:[navigationController_ view]];
	[window_ makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


- (void)dealloc {
	self.navigationController = nil;
	self.window = nil;
	[super dealloc];
}

#pragma mark - MPOAuthAPIDelegate Methods -

- (NSURL *)callbackURLForCompletedUserAuthorization {
	// The x-com-mpoauth-mobile URI is a claimed URI Type
	// check Info.plist for details
	return [NSURL URLWithString:@"x-com-mpoauth-mobile://success"];
}

- (NSString *)oauthVerifierForCompletedUserAuthorization {
	return oauthVerifier_;
}

- (BOOL)automaticallyRequestAuthenticationFromURL:(NSURL *)inAuthURL withCallbackURL:(NSURL *)inCallbackURL {
	return YES;
}
 
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	// the url is the callback url with the query string including oauth_token and oauth_verifier in 1.0a
	if ([[url host] isEqualToString:@"success"] && [url query].length > 0) {
		NSDictionary *oauthParameters = [MPURLRequestParameter parameterDictionaryFromString:[url query]];
		oauthVerifier_ = [oauthParameters objectForKey:@"oauth_verifier"];
	}
	 
	return YES;
}
 
@end
