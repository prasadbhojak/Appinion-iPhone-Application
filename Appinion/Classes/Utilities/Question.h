//
//  Question.h
//  Appinion
//
//  Created by Sunil Adhyaru on 10/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Question : NSObject {
	NSString* strQuestionID;				// ID of the question
	NSString* strBrandDescription;			// Description of the brand
	NSString* strBrandLogoURL;				// Link for brand logo
	NSString* strBrandLogoLink;				// Brand logo url
	int nBrandLogoStatus;					// Brand logo like status
	NSString* strQuestionTex;				// Question text
	NSMutableArray* arrAnswerType;			// Array for answers type
	NSMutableArray* arrAnswer;				// Array for answers
	NSMutableArray* arrAnswerImage;			// Images if answer type is image;
	NSData* dataBrandImage;					// brand image data
}

@property(nonatomic,retain)NSString* strQuestionID;
@property(nonatomic,retain)NSString* strBrandDescription;
@property(nonatomic,retain)NSString* strBrandLogoURL;
@property(nonatomic,retain)NSString* strBrandLogoLink;
@property(nonatomic)int nBrandLogoStatus;
@property(nonatomic,retain)NSString* strQuestionTex;
@property(nonatomic,retain)NSMutableArray* arrAnswerType;
@property(nonatomic,retain)NSMutableArray* arrAnswer;
@property(nonatomic,retain)NSMutableArray* arrAnswerImage;
@property(nonatomic,retain)NSData* dataBrandImage;

@end
