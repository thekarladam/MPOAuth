//
//  RootViewController.h
//  MPOAuthMobile
//
//  Created by Karl Adam on 08.12.14.
//  Copyright matrixPointer 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPOAuthAPI;

@interface RootViewController : UIViewController {
	MPOAuthAPI	*_oauthAPI;
	UITextField *methodInput;
	UITextField *parametersInput;
	UITextView	*textOutput;
}

@property (nonatomic, retain) IBOutlet UITextField *methodInput;
@property (nonatomic, retain) IBOutlet UITextField *parametersInput;

- (IBAction)clearCredentials;
- (IBAction)reauthenticate;

@end
