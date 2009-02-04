//
//  MPOAuthMobileAppDelegate.m
//  MPOAuthMobile
//
//  Created by Karl Adam on 08.12.14.
//  Copyright matrixPointer 2008. All rights reserved.
//

#import "MPOAuthMobileAppDelegate.h"
#import "RootViewController.h"
#import "UserAuthViewController.h"


@implementation MPOAuthMobileAppDelegate

@synthesize window;
@synthesize navigationController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

#pragma mark - MPOAuthAPIDelegate Methods -

- (NSURL *)callbackURLForCompletedUserAuthorization {
	// The x-com-mpoauth-mobile URI is a claimed URI Type
	// check Info.plist for details
	//return [NSURL URLWithString:@"x-com-mpoauth-mobile://success"];
	return nil;
}

- (BOOL)automaticallyRequestAuthenticationFromURL:(NSURL *)inAuthURL withCallbackURL:(NSURL *)inCallbackURL {
	UserAuthViewController *userAuthViewController = [[UserAuthViewController alloc] initWithURL:inAuthURL];
	[navigationController pushViewController:userAuthViewController animated:YES];
	[userAuthViewController release];
	
	return NO;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	// we're only setup to handle one URL so this pops the authentication webview
	[navigationController popViewControllerAnimated:YES];
	return YES;
}

@end
