//
//  state.m
//  Appinion
//
//  Created by Sunil Adhyaru on 09/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "state.h"

@implementation state

@synthesize strCountryID;
@synthesize strStateID;
@synthesize strStateCode;
@synthesize strName;

-(void)dealloc {
	[strCountryID release];
	[strStateID release];	
	[strStateCode release];
	[strName release];	
	[super dealloc];
}

@end
