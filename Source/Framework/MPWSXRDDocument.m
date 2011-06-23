//
//  MPWSXRDDocument.m
//  MPWwbServices
//
//  Created by Karl Adam on 09.03.31.
//  Copyright 2009 matrixPointer. All rights reserved.
//

#import "MPWSXRDDocument.h"
#import <libxml/parser.h>
#import <libxml/tree.h>
#import <libxml/xpathInternals.h>
#import <libxml/xpath.h>

@interface MPWSXRDDocument ()
@property (nonatomic, readwrite, retain) NSString *subject;
@property (nonatomic, readwrite, retain) NSDate *expirationDate;
@property (nonatomic, readwrite, retain) NSDictionary *urlRelationships;

- (BOOL)_parseStringForContent:(NSString *)inString;
@end

@implementation MPWSXRDDocument

- (id)initFromURL:(NSURL *)inURL {
	if ((self = [super init])) {
	}
	return self;
}

- (id)iniWithString:(NSString *)inString {
	if ((self = [super init])) {
		[self _parseStringForContent:inString];
	}
	return self;
}

- (oneway void)dealloc {
	self.subject = nil;
	self.expirationDate = nil;
	self.urlRelationships = nil;
	
	[super dealloc];
}

@synthesize subject = _subject;
@synthesize expirationDate = _expirationDate;
@synthesize urlRelationships = _urlRelationships;

#pragma mark -

- (BOOL)_parseStringForContent:(NSString *)inString {
	BOOL successfullyParsed = NO;
	
	xmlInitParser();
	const char *cStringForDoc = [inString UTF8String];
	xmlDocPtr xrdDocument = xmlParseMemory(cStringForDoc, strlen(cStringForDoc));
	if (xrdDocument) {
//		xmlNodePtr rootNode = xmlDocGetRootElement(xrdDocument);
		xmlXPathContextPtr xpathContext = xmlXPathNewContext(xrdDocument);
		xmlXPathObjectPtr xpathObject = NULL;
		
		xpathObject = xmlXPathEvalExpression((const xmlChar *)"/xrd[0]/subject", xpathContext);
		if (xpathObject) {
			xmlNodeSetPtr subjectNodes = xpathObject->nodesetval;
			int resultsCount = subjectNodes ? subjectNodes->nodeNr : 0;
			int i = 0;
			
			for ( ; i < resultsCount; i++) {
				
			}
		}
		xmlXPathFreeObject(xpathObject);
		
		xmlXPathFreeContext(xpathContext);
		xmlFreeDoc(xrdDocument);
	}
	xmlCleanupParser();
	
	return successfullyParsed;
}

- (NSURL *)urlForRelationship:(NSString *)inRelationshipType {
	NSURL *foundURL = [self.urlRelationships objectForKey:inRelationshipType];
	
	return foundURL;
}

@end
