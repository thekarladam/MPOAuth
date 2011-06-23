//
//  UserAuthViewController.m
//  MPOAuthMobile
//
//  Created by Karl Adam on 09.02.03.
//  Copyright 2009 matrixPointer. All rights reserved.
//

#import "UserAuthViewController.h"
#import "MPOAuthAPI.h"
#import "MPOAuthAuthenticationMethodOAuth.h"

@implementation UserAuthViewController

- (id)initWithURL:(NSURL *)inURL {
	if ((self = [super initWithNibName:@"UserAuthViewController" bundle:nil])) {
		self.title = @"User Auth";
		self.navigationItem.prompt = @"Request Authorization for this application";
		self.userAuthURL = inURL;
	}
	
	return self;
}

- (void)dealloc {
	self.userAuthURL = nil;
	
    [super dealloc];
}

@synthesize userAuthURL = _userAuthURL;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[webview setDelegate:self];
	[webview loadRequest:[NSURLRequest requestWithURL:self.userAuthURL]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - UIWebView Delegate Methods -

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	// this is a ghetto way to handle this, but it's for when you must use http:// URIs
	// so that this demo will work correctly, this is an example, DONT.BE.GHETTO
	NSURL *userAuthURL = [(id <MPOAuthAuthenticationMethodOAuthDelegate>)[UIApplication sharedApplication].delegate callbackURLForCompletedUserAuthorization];
	if ([request.URL isEqual:userAuthURL]) {
		[[self navigationController] popViewControllerAnimated:YES];
		return NO;
	}
	
	return YES;
}


@end
