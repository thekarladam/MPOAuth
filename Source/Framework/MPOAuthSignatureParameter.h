//
//  MPOAuthSignatureParameter.h
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.07.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPURLRequestParameter.h"

@class MPOAuthURLRequest;

@interface MPOAuthSignatureParameter : MPURLRequestParameter {

}

- (id)initWithText:(NSString *)inText andSecret:(NSString *)inSecret forRequest:(MPOAuthURLRequest *)inRequest usingMethod:(NSString *)inMethod;

@end
