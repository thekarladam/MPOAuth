//
//  UserAuthViewController.h
//  MPOAuthMobile
//
//  Created by Karl Adam on 09.02.03.
//  Copyright 2009 matrixPointer. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UserAuthViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *webview;
	NSURL *_userAuthURL;
}

@property (nonatomic, readwrite, retain) NSURL *userAuthURL;

@end
