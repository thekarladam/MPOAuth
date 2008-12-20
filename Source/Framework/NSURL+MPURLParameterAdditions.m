//
//  NSURL+MPURLParameterAdditions.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.08.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import "NSURL+MPURLParameterAdditions.h"
#import "MPURLRequestParameter.h"

@implementation NSURL (MPURLParameterAdditions)

- (NSURL *)urlByAddingParameters:(NSArray *)inParameters {
	NSMutableArray *parameters = [[NSMutableArray alloc] init];
	NSString *queryString = [self query];
	NSString *absoluteString = [self absoluteString];
	NSRange parameterRange = [absoluteString rangeOfString:@"?"];
	parameterRange.length = [absoluteString length] - parameterRange.location;

	[parameters addObjectsFromArray:[MPURLRequestParameter parametersFromString:[queryString substringWithRange:NSMakeRange(1, [queryString length]-1)]]];
	[parameters addObjectsFromArray:inParameters];
	
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [absoluteString substringToIndex:parameterRange.location], [MPURLRequestParameter parameterStringForParameters:[parameters autorelease]]]];
}

- (NSURL *)urlByAddingParameterDictionary:(NSDictionary *)inParameterDictionary {
	NSMutableDictionary *parameterDictionary = [[NSMutableDictionary alloc] init];
	NSString *queryString = [self query];
	NSString *absoluteString = [self absoluteString];
	NSRange parameterRange = [absoluteString rangeOfString:@"?"];
	parameterRange.length = [absoluteString length] - parameterRange.location;
	
	[parameterDictionary addEntriesFromDictionary:inParameterDictionary];
	[parameterDictionary addEntriesFromDictionary:[MPURLRequestParameter parameterDictionaryFromString:queryString]];
	
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [absoluteString substringToIndex:parameterRange.location], [MPURLRequestParameter parameterStringForDictionary:[parameterDictionary autorelease]]]];
}

- (NSString *)absoluteNormalizedString {
	NSString *normalizedString = [self absoluteString];

	if ([[self path] length] == 0 && [[self query] length] == 0) {
		normalizedString = [NSString stringWithFormat:@"%@/", [self absoluteString]];
	}
	
	return normalizedString;
}

@end
