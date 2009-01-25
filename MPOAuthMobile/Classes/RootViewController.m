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

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.navigationItem setPrompt:@"Performing Request Token Request"];
	[self.navigationItem setTitle:@"OAuth Test"];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestTokenReceived:) name:MPOAuthNotificationRequestTokenReceived object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenReceived:) name:MPOAuthNotificationAccessTokenReceived object:nil];
	
	NSDictionary *credentials = [NSDictionary dictionaryWithObjectsAndKeys:	kConsumerKey, kMPOAuthCredentialConsumerKey,
																			kConsumerSecret, kMPOAuthCredentialConsumerSecret,
								 nil];
	_oauthAPI = [[MPOAuthAPI alloc] initWithCredentials:credentials
											  andBaseURL:[NSURL URLWithString:@"http://term.ie/oauth/example/"]];
	
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)dealloc {
    [super dealloc];
}

- (void)requestTokenReceived:(NSNotification *)inNotification {
	[self.navigationItem setPrompt:@"Awaiting User Authentication"];
}

- (void)accessTokenReceived:(NSNotification *)inNotification {
	[self.navigationItem setPrompt:@"Access Token Received"];
}


@end

