//
//  country.m
//  Appinion
//
//  Created by Sunil Adhyaru on 09/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "country.h"


@implementation country

@synthesize strID;
@synthesize strName;

-(void)dealloc {
	[strID release];
	[strName release];	
	[super dealloc];
}

@end
