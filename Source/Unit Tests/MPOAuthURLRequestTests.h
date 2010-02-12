//
//  MPOAuthURLRequestTests.h
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.18.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>
#import "MPOAuthURLRequest.h"
#import "MPOAuthCredentialStore.h"

@interface MPOAuthURLRequestTests : SenTestCase {
	MPOAuthURLRequest *_request;
	id <MPOAuthCredentialStore> _credentials;
}

@end
