//
//  LoginViewController.h
//  Appinion
//
//  Created by Sunil Adhyaru on 02/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignupViewController.h"
#import "QuestionsViewController.h"
#import "defines.h"
#import "AppinionAppDelegate.h"
#import "SBJSON.h"

#define WEB_SERVICE_CALL_LOGIN									0
#define WEB_SERVICE_CALL_GET_INCREMENT_VALUE_OF_CREDIT_COUNT	1
#define WEB_SERVICE_CALL_GET_TOTAL_CREDIT_COUNTS				2
#define WEB_SERVICE_CALL_GET_TOTAL_QUESTION_COUNT				3

@interface LoginViewController : UIViewController {
	IBOutlet UITextField* txtEmail;					// text field for username
	IBOutlet UITextField* txtPassword;				// text field for password
	NSURLConnection *theConnection;					// object used to make http connection
	NSMutableData* receivedData;					// data used to collect http reponse
	IBOutlet UIButton* BtnRemember;					//Button For remember Login
	NSMutableDictionary* dictLogin;
	NSMutableArray* ArrLogin;
	IBOutlet UISwitch* RememberLogin;				// switch ON /OFF for remember login 
	NSUserDefaults *defaults;
	bool bSaveCrentialsNeedTobeSaved;
	int nCurrentWebServiceCall;
}
-(BOOL)validateEmail: (NSString *) email;
-(IBAction)OnButtonLogin:(id)sender;
-(IBAction)OnButtonSignup:(id)sender;
-(IBAction)OnSwitchClieck:(id)sender;
//-(IBAction)Remember_me_clicked:(id)sender;
-(IBAction)OnButtonHome:(id)sender;
@end
