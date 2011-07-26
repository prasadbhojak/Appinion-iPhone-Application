//
//  LoginViewController.m
//  Appinion
//
//  Created by Sunil Adhyaru on 02/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSString* strUserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"];
	NSString* strPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPassword"];
	
	if([strUserName length] > 0 && [strPassword length] > 0) {
		txtEmail.text = strUserName;
	}

}


-(IBAction)OnButtonLogin:(id)sender {
	
	if(APP_DELEGATE.netStatus == NotReachable) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Internet connection is not available. Please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		[[ActivityIndicator sharedActivityIndicator] hide];
		return;
	}
	
	if([txtEmail.text length] < 1 ) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Please enter email address" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if([txtPassword.text length] < 1 ) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Please enter password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if(![self validateEmail:txtEmail.text]){
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Please enter valid email address" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	[[ActivityIndicator sharedActivityIndicator] show];
	
	APP_DELEGATE.bLoginFromSavedCredentials = NO;
	nCurrentWebServiceCall = WEB_SERVICE_CALL_LOGIN;
	
	NSString* strURL = @"";
	strURL = [strURL stringByAppendingString:BASE_URL];
	strURL = [strURL stringByAppendingString:@"?action=login"];
	strURL = [strURL stringByAppendingFormat:@"&username=%@",[txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	strURL = [strURL stringByAppendingFormat:@"&password=%@",[txtPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	if([APP_DELEGATE._deviceToken length] > 0)
		strURL = [strURL stringByAppendingFormat:@"&deviceid=%@",APP_DELEGATE._deviceToken];
	else
		strURL = [strURL stringByAppendingString:@"&deviceid="];		

	NSString * encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)strURL,NULL,(CFStringRef)@" ",kCFStringEncodingUTF8 );
	NSURLRequest* urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:encodedString]];
	
	if(theConnection != nil) {
		[theConnection cancel];
		[theConnection release];
		theConnection = nil;
	}
	theConnection=[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	receivedData = [[NSMutableData data] retain];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection  didFailWithError:(NSError *)error
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Cannot connect to server. Please try later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[[ActivityIndicator sharedActivityIndicator] hide];	
	[connection release];
	theConnection = nil;
    [receivedData release];	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {	
	AppinionAppDelegate* appDel = [[UIApplication sharedApplication] delegate];
	
	if(nCurrentWebServiceCall == WEB_SERVICE_CALL_LOGIN) { // Handle login response
		NSString* strResponse = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
		[receivedData release];
		
		SBJSON* json = [[SBJSON alloc] init];
		NSError* error = nil;
		NSDictionary *results = [json objectWithString:strResponse error:&error];		
		NSArray* arrItems = [results objectForKey:@"appinion"];
		NSDictionary *firstItem = [arrItems objectAtIndex:0];
		NSString* strMessage = [firstItem valueForKey:@"message"];
		if([strMessage isEqualToString:@"Login Successful"]) { // valid credentials , Now get credit points 		
			APP_DELEGATE.bIsUserLoggedIn = YES;
			
			if(bSaveCrentialsNeedTobeSaved) {
				defaults = [NSUserDefaults standardUserDefaults];
				[defaults setObject:txtEmail.text forKey:@"UserID"];
				[defaults setObject:txtPassword.text forKey:@"UserPassword"];
				[defaults setObject:APP_DELEGATE._deviceToken forKey:@"UDID"];
				[[NSUserDefaults standardUserDefaults] synchronize];
			}else { 
				defaults = [NSUserDefaults standardUserDefaults];
				[defaults setObject:@"" forKey:@"UserID"];
				[defaults setObject:@"" forKey:@"UserPassword"];
				[defaults setObject:@"" forKey:@"UDID"];
				[[NSUserDefaults standardUserDefaults] synchronize];
			}
			
			for(UIViewController* vc in APP_DELEGATE.navController.viewControllers) {	
				if([vc.nibName isEqualToString:@"HomeViewController"]) {
					HomeViewController* homeVC = (HomeViewController*)vc;
					[homeVC.btnLogin setTitle:@"Logout" forState:UIControlStateNormal];
				}		
			}
			
			nCurrentWebServiceCall = WEB_SERVICE_CALL_GET_INCREMENT_VALUE_OF_CREDIT_COUNT;
			
			NSString* strUserID = [firstItem valueForKey:@"user_id"];
			APP_DELEGATE.nUserID = [strUserID integerValue];
			NSString* strURL = @"";
			strURL = [strURL stringByAppendingString:BASE_URL];
			strURL = [strURL stringByAppendingString:@"?action=credit_data"];
			strURL = [strURL stringByAppendingFormat:@"&user_id=%d",appDel.nUserID];		
			NSString * encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)strURL,NULL,(CFStringRef)@" ",kCFStringEncodingUTF8 );
			NSURLRequest* urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:encodedString]];
			if(theConnection != nil) {
				[theConnection cancel];
				[theConnection release];
				theConnection = nil;
			}
			theConnection=[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
			receivedData = [[NSMutableData data] retain];
		}
		else {						// Invalid credentials
			[txtEmail resignFirstResponder];
			[txtPassword resignFirstResponder];
			[[ActivityIndicator sharedActivityIndicator] hide];
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:strMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			return;
		}
	}
	else if(nCurrentWebServiceCall == WEB_SERVICE_CALL_GET_INCREMENT_VALUE_OF_CREDIT_COUNT){								// handle credit point increment value 
		NSString* strResponse = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
		[receivedData release];
		SBJSON *json = [[SBJSON alloc] init];
		NSError *error = nil;
		NSDictionary *results = [json objectWithString:strResponse error:&error];		
		NSArray* arrItems = [results objectForKey:@"appinion"];
		NSDictionary* firstItem = [arrItems objectAtIndex:0];
		NSString* strCreditPoint = [firstItem objectForKey:@"total_credit"];
		APP_DELEGATE.nCreditPointIncreseCount = [strCreditPoint integerValue];	
		[APP_DELEGATE getLocallySavedItems];
		
		nCurrentWebServiceCall = WEB_SERVICE_CALL_GET_TOTAL_CREDIT_COUNTS;
		NSString* strURL = @"";
		strURL = [strURL stringByAppendingString:BASE_URL];
		strURL = [strURL stringByAppendingString:@"?action=credit_info"];
		strURL = [strURL stringByAppendingFormat:@"&user_id=%d",APP_DELEGATE.nUserID];		
		NSString * encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)strURL,NULL,(CFStringRef)@" ",kCFStringEncodingUTF8 );
		NSURLRequest* urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:encodedString]];
		if(theConnection != nil) {
			[theConnection cancel];
			[theConnection release];
			theConnection = nil;
		}
		theConnection=[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
		receivedData = [[NSMutableData data] retain];
	}
	else if(nCurrentWebServiceCall == WEB_SERVICE_CALL_GET_TOTAL_CREDIT_COUNTS){
		NSString* strResponse = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
		[receivedData release];
		SBJSON *json = [[SBJSON alloc] init];
		NSError *error = nil;
		NSDictionary *results = [json objectWithString:strResponse error:&error];		
		NSArray* arrItems = [results objectForKey:@"appinion"];
		NSDictionary* firstItem = [arrItems objectAtIndex:0];
		//lblCreditCount.text  = [firstItem objectForKey:@"credit_points"];
		[APP_DELEGATE saveCreditCountLocally:[firstItem objectForKey:@"credit_points"]];
		nCurrentWebServiceCall = WEB_SERVICE_CALL_GET_TOTAL_QUESTION_COUNT;
		NSString* strURL = @"";
		strURL = [strURL stringByAppendingString:BASE_URL];
		strURL = [strURL stringByAppendingString:@"?action=get_question_count"];
		strURL = [strURL stringByAppendingFormat:@"&user_id=%d",APP_DELEGATE.nUserID];		
		NSString * encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)strURL,NULL,(CFStringRef)@" ",kCFStringEncodingUTF8 );
		NSURLRequest* urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:encodedString]];
		if(theConnection != nil) {
			[theConnection cancel];
			[theConnection release];
			theConnection = nil;
		}
		theConnection=[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
		receivedData = [[NSMutableData data] retain];
	}
	else if(nCurrentWebServiceCall == WEB_SERVICE_CALL_GET_TOTAL_QUESTION_COUNT) {
		NSString* strResponse = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
		[receivedData release];
		SBJSON *json = [[SBJSON alloc] init];
		NSError *error = nil;
		NSDictionary *results = [json objectWithString:strResponse error:&error];		
		NSArray* arrItems = [results objectForKey:@"appinion"];
		NSDictionary* firstItem = [arrItems objectAtIndex:0];		
		//lblQuestionCount.text = [NSString stringWithFormat:@"%d",[[firstItem objectForKey:@"total_question"] integerValue]];
		[APP_DELEGATE saveQuestionCountLocally:[NSString stringWithFormat:@"%d",[[firstItem objectForKey:@"total_question"] integerValue]]];
		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[firstItem objectForKey:@"total_question"] integerValue]];

		[[ActivityIndicator sharedActivityIndicator] hide];
		 QuestionsViewController* _QuestionsViewController = [[QuestionsViewController alloc] initWithNibName:@"QuestionsViewController" bundle:nil];
		 [APP_DELEGATE.navController pushViewController:_QuestionsViewController animated:YES];
		 [_QuestionsViewController release];
	}
	

}
-(IBAction)OnSwitchClieck:(id)sender{
	
	if(RememberLogin.on) {
		bSaveCrentialsNeedTobeSaved = YES;
	}else { 
		bSaveCrentialsNeedTobeSaved = NO;
	}
}


-(BOOL)validateEmail: (NSString *) email {
	NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	BOOL isValid = [emailTest evaluateWithObject:email];
	return isValid;
}

-(IBAction)OnButtonSignup:(id)sender {
	SignupViewController* _SignupViewController = [[SignupViewController alloc] initWithNibName:@"SignupViewController" bundle:nil];
	[APP_DELEGATE.navController pushViewController:_SignupViewController animated:YES];
	[_SignupViewController release];
}

-(IBAction)OnButtonHome:(id)sender {
	for(UIViewController* vc in APP_DELEGATE.navController.viewControllers) {	
		if([vc.nibName isEqualToString:@"HomeViewController"]) {
			HomeViewController* homeVC = (HomeViewController*)vc;
			[APP_DELEGATE.navController popToViewController:homeVC animated:YES];		
		}		
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	//if(textField.tag == 1000){
//		NSArray* temp = [[NSUserDefaults standardUserDefaults] objectForKey:@"User"];
//		for (int i =0; i<[temp count]; i++) {
//			if([textField.text isEqualToString:[[temp objectAtIndex:i] objectForKey:@"UserID"]]){
//				NSLog(@"text field match",[[temp objectAtIndex:i] objectForKey:@"UserID"]);
//			}
//		}
//	}
	if(textField.tag == 1001) {// password field
		[self OnButtonLogin:nil];
	} 
	[textField resignFirstResponder];
	return YES;
}
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	if(theConnection) {
		[theConnection release];
		theConnection = nil;
	}
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
