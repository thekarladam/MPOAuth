//
//  UserAuthViewController.m
//  MPOAuthMobile
//
//  Created by Karl Adam on 09.02.03.
//  Copyright 2009 Yahoo. All rights reserved.
//

#import "UserAuthViewController.h"
#import "MPOAuthAPI.h"

@implementation UserAuthViewController

- (id)initWithURL:(NSURL *)inURL {
	if (self = [super initWithNibName:@"UserAuthViewController" bundle:nil]) {
		self.title = @"User Auth";
		self.navigationItem.prompt = @"Request Authorizion for this application";
		self.userAuthURL = inURL;
	}
	
	return self;
}

- (void)dealloc {
    [super dealloc];
}

@synthesize userAuthURL = _userAuthURL;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
	[webview loadRequest:[NSURLRequest requestWithURL:self.userAuthURL]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark - UIWebView Delegate Methods -

- (void)webViewDidStartLoad:(UIWebView *)webView {
	// this is a ghetto way to handle this, but it's for when you must use http:// URIs
	// so that this demo will work correctly, this is an example, DONT.BE.GHETTO
	NSURL *userAuthURL = [(id <MPOAuthAPIDelegate>)[UIApplication sharedApplication].delegate callbackURLForCompletedUserAuthorization];
	if ([webview.request.URL isEqual:userAuthURL]) {
		[[self navigationController] popViewControllerAnimated:YES];
	}
}


@end
