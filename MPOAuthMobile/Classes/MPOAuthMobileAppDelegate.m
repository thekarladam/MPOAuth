//
//  MPOAuthMobileAppDelegate.m
//  MPOAuthMobile
//
//  Created by Karl Adam on 08.12.14.
//  Copyright Yahoo 2008. All rights reserved.
//

#import "MPOAuthMobileAppDelegate.h"
#import "RootViewController.h"


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

@end
