//
//  QuestionsViewController.h
//  Appinion
//
//  Created by Sunil Adhyaru on 06/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoViewController.h"
#import "ActivityIndicator.h"
#import "defines.h"
#import "AppinionAppDelegate.h"
#import "LoginViewController.h"
#import "Question.h"
#import "Answer.h"
#import "HomeViewController.h"

#define WEB_SERVICE_CALL_GET_QUESTION						0
#define WEB_SERVICE_CALL_POST_ANSWER						1
#define WEB_SERVICE_CALL_POST_DEVICE_ID						2
#define WEB_SERVICE_CALL_GET_BRAND_LIKE_STATUS				3
#define WEB_SERVICE_CALL_POST_UNPOSTED_ANSWER				4
#define WEB_SERVICE_CALL_POST_UNPOSTED_BRAND_LIEK_STATUS	5

#define SCROLL_VIEW_DIRECTION_UP							0
#define SCROLL_VIEW_DIRECTION_DOWN							1

@interface QuestionsViewController : UIViewController<UIScrollViewDelegate> {
	IBOutlet UIButton* btnBrand;					// button for brand
	IBOutlet UIImageView* imgViewBrandBack;			// brand image background
	IBOutlet UILabel* lblBrand;						// label for brand
	IBOutlet UILabel* lblQuestion;					// label for question
	IBOutlet UIScrollView* scrAnswers;				// scroll view for answers	
	int nNoOfAnswers;								// count for number of answers
	int nSelectedAnswer;							// index of selected answer
	int nCurrentWebserviceCall;						// index of current web service call
	NSURLConnection *theConnection;					// object used to make http connection
	NSMutableData* receivedData;					// data used to collect http reponse
	int nQuestionID;								// ID of the question
	Question* currentQuestion;						// current question;	
	int nCurrentQuestionNumber;						// current question number
	IBOutlet UIImageView* arrowUpDown;
	int nScrollViewDirection;						// direction of scroll view (up/down)
	int lastContentOffset;							// scroll view last content offset
	BOOL bUserScrolledAllAnswers;					// flag indicating whether user scroll through all answers
	BOOL bIsUnpostedAnswerPostedOnHomeButton;		// 
	bool bShowIntroScreen;	
	IBOutlet UIView* viewIntro;						// view for introduction screen
	IBOutlet UIView* animationView;					// view to be used for animation
	IBOutlet UIButton* btnSkip;						// button skip
	IBOutlet UIButton* btnSumbit;					// button sumbit
}

-(void)getQuestion;
-(void)postUnpostedAnswer;
-(void)postDeviceID;
-(void)addAnswersToScrollView;
-(void)moveToNextQuestion;
-(void)showNextQuestion;
-(void)saveQuestionArrayLocally;
-(void)saveUnpostedAnswerArrayLocally;
-(void)moveToHomeScreen;
-(void)clearQuestionArray;
-(void)clearQuestionScreen;
+(UIImage *) resizeImage:(UIImage *)orginalImage resizeSize:(CGSize)size;
-(IBAction)OnButtonSubmit:(id)sender;
-(IBAction)OnButtonHome:(id)sender;
-(IBAction)OnButtonAnswer:(id)sender;
-(IBAction)OnButtonInfo:(id)sender;
-(IBAction)OnButtonBrand:(id)sender;
@end
