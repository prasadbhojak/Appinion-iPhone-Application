//
//  SignupViewController.h
//  Appinion
//
//  Created by Sunil Adhyaru on 02/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoViewController.h"
#import "ActivityIndicator.h"
#import "defines.h"
#import "AppinionAppDelegate.h"
#import "SBJSON.h"
#import "country.h"
#import "state.h"
#import "city.h"
#import "QuestionsViewController.h"
#import "SelectCountryViewCountry.h"
#import "FBConnect/FBConnect.h"


#define TEXT_FIELD_SECURITY_QUESTION	1003
#define TEXT_FIELD_BIRTH_YEAR			1007
#define TEXT_FIELD_GENDER				1008
#define TEXT_FIELD_COUNTRY				1009
#define TEXT_FIELD_STATE				1010
#define TEXT_FIELD_CITY					1011

#define WEB_SERVICE_CALL_COUNTRY_LIST		0
#define WEB_SERVICE_CALL_SUBMIT				1
#define WEB_SERVICE_CALL_SUBMIT_FACEBOOK	2

@interface SignupViewController : UIViewController <UITextFieldDelegate,UIPickerViewDelegate,FBSessionDelegate, FBRequestDelegate,FBDialogDelegate> {
	bool bIsStep1;
	IBOutlet UIView* viewStep1;					// view for step1 
	IBOutlet UIView* viewStep2;					// view for step2 
	IBOutlet UIView* viewMain;					// view for main controls 
	IBOutlet UILabel* lblStep1;					// label for step1
	IBOutlet UILabel* lblStep2;					// label for step2
	IBOutlet UIButton* btnStep1;				// button step1
	IBOutlet UIButton* btnStep2;				// button step2
	
	// controls for step1
	IBOutlet UITextField* txtEmail;				// text field for email id
	IBOutlet UITextField* txtPassword;			// text field for password
	IBOutlet UITextField* txtVerifyPassword;	// text field for verify password
	IBOutlet UITextField* txtSecurityQuestion;	// text field for security question
	IBOutlet UITextField* txtSecurityAnswer;	// text field for security answer
	IBOutlet UIButton* btnNext;					// button for move to step 2
	UIButton* btnSubmit;
	
	// controls for step2
	IBOutlet UITextField* txtGender;			// text field for Gender
	IBOutlet UITextField* txtBirthyear;			// text field for birth year
	IBOutlet UITextField* txtCountry;			// text field for country
	IBOutlet UITextField* txtCity;				// text field for city
	IBOutlet UITextField* txtState ;			// text field for state
	IBOutlet UITextField* txtFirstName ;		// text field for first name
	IBOutlet UITextField* txtZipcode ;			// text field for zip code

	IBOutlet UIPickerView* picker;				// picker for various items	
	IBOutlet UIToolbar* pickerToolbar;			// toolbar to hide picker
	bool bIsViewMovedUp;						// flag indicating that view is moved up
	NSArray* arrSecurityQuestions;				// Array for security questions
	NSArray* arrGender;							// Array for Genders
	NSMutableArray* arrYear;					// Array for birth year
	int nCurrentPickerIndex;					// index indicating which picker to be shown
	UITextField* currentTextField;				//
	
	int nSecurityQuestionCurrentItem;			// currently selected security question
	int nBirthYearCurrentItem;					// currently selected birth year item
	int nGenderCurrentItem;						// currently selected gender
	int nCurrentWebServiceCall;					// index of current web service call
	
	NSURLConnection *theConnection;				// object used to make http connection
	NSMutableData* receivedData;				// data used to collect http reponse
	
	NSMutableString *currentElementValue;		// stores parsed value
	NSString* strResponseMessage;				// webservice response message			
	
	NSMutableArray* arrTempState;				// temp array for state;
	NSMutableArray* arrTempCity;				// temp array for city;	
	
	// FaeBook ....
	FBSession* _session;
	FBLoginDialog *_loginDialog;
	NSString *_facebookName;
	BOOL _posting;
	
	IBOutlet UIView* viewSplash;
	IBOutlet UILabel* lblSplash;
	
}
@property (nonatomic, retain) FBSession *session;
@property (nonatomic, retain) FBLoginDialog *loginDialog;
@property (nonatomic, copy) NSString *facebookName;

-(BOOL)validateEmail: (NSString *) email;
-(void)clearDetails;
-(void)initLocationItems;
-(IBAction)OnButtonBack:(id)sender;
-(IBAction)OnButtonHome:(id)sender;
-(IBAction)OnButtonSubmit:(id)sender;
-(IBAction)OnButtonNext:(id)sender;
-(IBAction)OnButtonStep2:(id)sender;
-(IBAction)OnButtonStep1:(id)sender;
-(IBAction)OnButtonInfo:(id)sender;
-(IBAction)OnButtonPickerDone:(id)sender;
-(IBAction)OnButtonSelectCountry:(id)sender;
-(void)moveToHome;

// FaeBook ....
- (void)FacebookTapped;
//- (IBAction)logoutButtonTapped:(id)sender;
- (void)getFacebookName;



@end
