//
//  Answer.h
//  Appinion
//
//  Created by Sunil Adhyaru on 12/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Answer : NSObject {
	NSString* strQuestionsID;			// ID of the question for this answer
	NSString* strUsersID;				// ID of the user of this question's owner
	NSString* strAnswerText;			// Answer text
	NSString* strSubmitted;				// flag indicating whether answer was submitted or skipped
}

@property(nonatomic,retain)NSString* strQuestionsID;
@property(nonatomic,retain)NSString* strAnswerText;
@property(nonatomic,retain)NSString* strUsersID;
@property(nonatomic,retain)NSString* strSubmitted;

@end
