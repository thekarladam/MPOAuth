//
//  MPOAuthCredentialConcreteStoreKeychainTests.h
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.18.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>
#import "MPOAuthCredentialConcreteStore.h"
#import "MPOAuthCredentialConcreteStore+KeychainAdditions.h"

@interface MPOAuthCredentialConcreteStoreKeychainTests : SenTestCase {
	MPOAuthCredentialConcreteStore *store_;
}

@end
