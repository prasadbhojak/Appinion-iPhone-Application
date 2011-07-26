//
//  Answer.m
//  Appinion
//
//  Created by Sunil Adhyaru on 12/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Answer.h"


@implementation Answer

@synthesize strQuestionsID;
@synthesize strAnswerText;
@synthesize strUsersID;
@synthesize strSubmitted;

-(void)dealloc {	
	[strQuestionsID release];
	[strAnswerText release];
	[strUsersID release];
	[strSubmitted release];
 	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder{
	self = [super init];
	strQuestionsID = [[coder decodeObjectForKey:@"strQuestionsID"] retain];
	strAnswerText = [[coder decodeObjectForKey:@"strAnswerText"] retain];
	strUsersID = [[coder decodeObjectForKey:@"strUsersID"] retain];
	strSubmitted = [[coder decodeObjectForKey:@"strSubmitted"] retain];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:strQuestionsID forKey:@"strQuestionsID"];
	[coder encodeObject:strAnswerText forKey:@"strAnswerText"];
	[coder encodeObject:strUsersID forKey:@"strUsersID"];
	[coder encodeObject:strSubmitted forKey:@"strSubmitted"];
}	
@end
