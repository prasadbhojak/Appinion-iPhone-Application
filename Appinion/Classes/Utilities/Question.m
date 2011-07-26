//
//  Question.m
//  Appinion
//
//  Created by Sunil Adhyaru on 10/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Question.h"

@implementation Question

@synthesize strQuestionID;
@synthesize strBrandDescription;
@synthesize strBrandLogoURL;
@synthesize strBrandLogoLink;
@synthesize nBrandLogoStatus;
@synthesize strQuestionTex;
@synthesize arrAnswerType;
@synthesize arrAnswer;
@synthesize arrAnswerImage;
@synthesize dataBrandImage;

-(void)dealloc {
	[strQuestionID release];
	[strBrandDescription release];
	[strBrandLogoURL release];
	[strBrandLogoLink release];
	[strQuestionTex release];
	[arrAnswerType release];	
	[arrAnswer release];	
	[arrAnswerImage release]; 
	[dataBrandImage release]; 
	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder{
	self = [super init];
	strQuestionID = [[coder decodeObjectForKey:@"strQuestionID"] retain];
	strBrandDescription = [[coder decodeObjectForKey:@"strBrandDescription"] retain];
	strBrandLogoURL = [[coder decodeObjectForKey:@"strBrandLogoURL"] retain];
	strBrandLogoLink = [[coder decodeObjectForKey:@"strBrandLogoLink"] retain];
	nBrandLogoStatus = [[[coder decodeObjectForKey:@"nBrandLogoStatus"] retain] integerValue];
	strQuestionTex = [[coder decodeObjectForKey:@"strQuestionTex"] retain];
	arrAnswerType = [[coder decodeObjectForKey:@"arrAnswerType"] retain];
	arrAnswer = [[coder decodeObjectForKey:@"arrAnswer"] retain];
	arrAnswerImage = [[coder decodeObjectForKey:@"arrAnswerImage"] retain];
	dataBrandImage = [[coder decodeObjectForKey:@"dataBrandImage"] retain];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:strQuestionID forKey:@"strQuestionID"];
	[coder encodeObject:strBrandDescription forKey:@"strBrandDescription"];
	[coder encodeObject:strBrandLogoURL forKey:@"strBrandLogoURL"];
	[coder encodeObject:strBrandLogoLink forKey:@"strBrandLogoLink"];
	[coder encodeObject:[NSString stringWithFormat:@"%d",nBrandLogoStatus] forKey:@"nBrandLogoStatus"];
	[coder encodeObject:strQuestionTex forKey:@"strQuestionTex"];
	[coder encodeObject:arrAnswerType forKey:@"arrAnswerType"];
	[coder encodeObject:arrAnswer forKey:@"arrAnswer"];
	[coder encodeObject:arrAnswerImage forKey:@"arrAnswerImage"];
	[coder encodeObject:dataBrandImage forKey:@"dataBrandImage"];
}	

@end
