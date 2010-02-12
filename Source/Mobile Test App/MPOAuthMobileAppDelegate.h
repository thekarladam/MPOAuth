//
//  MPOAuthMobileAppDelegate.h
//  MPOAuthMobile
//
//  Created by Karl Adam on 08.12.14.
//  Copyright matrixPointer 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MPOAuthAPI.h"

@interface MPOAuthMobileAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow				*window_;
    UINavigationController	*navigationController_;
	NSString				*oauthVerifier_;
}

@property (nonatomic, readwrite, retain) IBOutlet UIWindow *window;
@property (nonatomic, readwrite, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, readwrite, copy) NSString *oauthVerifier;
@end

