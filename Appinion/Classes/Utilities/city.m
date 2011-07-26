//
//  city.m
//  Appinion
//
//  Created by Sunil Adhyaru on 09/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "city.h"


@implementation city

@synthesize strStateCode;
@synthesize strName;

-(void)dealloc {
	[strStateCode release];
	[strName release];	
	[super dealloc];
}
@end
