//
//  OAuthClientController.h
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.05.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MPOAuth/MPOAuth.h>

@class MPOAuthAPI;

@interface OAuthClientController : NSObject {
	IBOutlet	NSTextField			*baseURLField;
	IBOutlet	NSTextField			*authenticationURLField;
	IBOutlet	NSTextField			*consumerKeyField;
	IBOutlet	NSTextField			*consumerSecretField;
	IBOutlet	NSButton			*authenticationButton;
	IBOutlet	NSProgressIndicator *progressIndicator;
	IBOutlet	NSTextField			*methodField;
	IBOutlet	NSTextField			*requestBodyField;
	IBOutlet	NSTextView			*responseBodyView;
				MPOAuthAPI			*_oauthAPI;
}

- (IBAction)performAuthentication:(id)sender;
- (IBAction)performMethod:(id)sender;

@end
