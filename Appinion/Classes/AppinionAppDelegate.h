//
//  AppinionAppDelegate.h
//  Appinion
//
//  Created by Sunil Adhyaru on 02/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "defines.h"
#import "Reachability.h"
#import "ActivityIndicator.h"
#import "Answer.h"
#import "SBJSON.h"
#import "QuestionsViewController.h"

#define WEB_SERVICE_CALL_LOGIN									0
#define WEB_SERVICE_CALL_GET_INCREMENT_VALUE_OF_CREDIT_COUNT	1
#define WEB_SERVICE_CALL_GET_TOTAL_CREDIT_COUNTS				2
#define WEB_SERVICE_CALL_GET_TOTAL_QUESTION_COUNT				3

@class ActivityIndicator;

@interface AppinionAppDelegate : NSObject <UIApplicationDelegate> {    
    UIWindow *window;
    UINavigationController *navController;						// navigatoin controller
	NetworkStatus netStatus;									// Network status	
	int nCreditPointIncreseCount;								// credit point
	int nUserID;												// current logged in user id
	NSMutableArray* arrCity;									// array of cities
	NSMutableArray* arrCountry;									// array of countries
	NSMutableArray* arrState;									// array of states
	NSMutableArray* arrQuestions;								// array of questions
	int nCurrentQuestionIndex;									// index of current question from buffer
	NSMutableArray* arrUnpostedAnswers;							// Array of posted answers during offline run of the app
	NSString *_deviceToken, *payload, *certificate;				// Strings for push notification
	bool bIsWebserviceForLogin;									// Flag indicating its for login and not credit point
	NSURLConnection *theConnection;								// object used to make http connection
	NSMutableData* receivedData;								// data used to collect http reponse
	bool bIsUserLoggedIn;										// Flag indicating whether user is currently logged in or not
	NSString* strSelectedCountry;								// selected country
	NSString* strSelectedCountryID;								// selected country id
	NSString* strSelectedState;									// selected state
	NSString* strSelectedStateID;								// selected state id
	NSString* strSelectedCity;									// selected city
	NSString* strSelectedCityID;								// seletec city id
	NSString* strQuestionCount;									// Total question count
	NSString* strCreditCount;									// Total credit count
	NSDictionary* dictPushnotification;							// dictionary for push notification data
	int nCurrentWebserviceCall;
	bool bLoginFromSavedCredentials;							// flag indicating whether login is from saved credentials
	int nQuestionDelay;										// time required to enable the submit button in question screen

}

-(void)getLocallySavedItems;
-(NSString*)getLocallySavedQuestionCount;
-(void)saveQuestionCountLocally:(NSString*)QuestionCount;
-(NSString*)getLocallySavedCreditCount;
-(void)saveCreditCountLocally:(NSString*)CreditCount;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic) int nCreditPointIncreseCount;
@property (nonatomic) int nUserID;
@property (nonatomic) int nCurrentQuestionIndex;
@property NetworkStatus netStatus;
@property (nonatomic, retain) NSMutableArray* arrCity;
@property (nonatomic, retain) NSMutableArray* arrCountry;
@property (nonatomic, retain) NSMutableArray* arrState;
@property (nonatomic, retain) NSMutableArray* arrQuestions;
@property (nonatomic, retain) NSMutableArray* arrUnpostedAnswers;
@property (nonatomic, retain) NSString* _deviceToken;
@property (nonatomic, retain) NSString* payload;
@property (nonatomic, retain) NSString* certificate;
@property (nonatomic, retain) NSString* strSelectedCountry;
@property (nonatomic, retain) NSString* strSelectedCountryID;
@property (nonatomic, retain) NSString* strSelectedState;
@property (nonatomic, retain) NSString* strSelectedStateID;
@property (nonatomic, retain) NSString* strSelectedCity;
@property (nonatomic, retain) NSString* strSelectedCityID;
@property (nonatomic, retain) NSString* strQuestionCount;
@property (nonatomic, retain) NSString* strCreditCount;
@property (nonatomic) bool bLoginFromSavedCredentials;
@property (nonatomic) bool bIsUserLoggedIn;
@property (nonatomic) int nQuestionDelay;

@end

