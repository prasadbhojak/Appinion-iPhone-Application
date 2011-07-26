//
//  SignupViewController.m
//  Appinion
//
//  Created by Sunil Adhyaru on 02/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SignupViewController.h"


@implementation SignupViewController
@synthesize session = _session;
@synthesize loginDialog = _loginDialog;
@synthesize facebookName = _facebookName;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if(APP_DELEGATE.netStatus == NotReachable) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Internet connection is not available. Please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		[[ActivityIndicator sharedActivityIndicator] hide];
		return;
	}	
	static NSString* kApiKey = @"105678812858191";
	static NSString* kApiSecret = @"6718868ec31728a6ba3aea0d736cec26";
	_session = [[FBSession sessionForApplication:kApiKey secret:kApiSecret delegate:self] retain];
	[_session logout];
	// Load a previous session from disk if available.  Note this will call session:didLogin if a valid session exists.
	//[_session resume];
	
	
	bIsStep1 = TRUE;
	btnStep2.enabled = NO;
	
	[lblStep1 setFont:[UIFont boldSystemFontOfSize:14]];
	lblStep1.textColor = [UIColor blackColor];
	[lblStep2 setFont:[UIFont systemFontOfSize:14]];
	lblStep2.textColor = [UIColor grayColor];
	
	viewStep1.frame = CGRectMake(15, 37, 290, 370);
	[viewMain addSubview:viewStep1];	
	
	viewStep2.frame = CGRectMake(15, 37, 290, 370);	
	[viewMain addSubview:viewStep2];
	viewStep2.hidden = YES;
	
	[self.view sendSubviewToBack:viewMain];
	bIsViewMovedUp = YES;
	
	arrSecurityQuestions = [[NSArray alloc] initWithObjects:@"Select Question",
													 @"What was your childhood nickname?",
													 @"What is the name of your favorite childhood friend?",
													 @"What is your pet's name?",
													 @"What was your favorite sport in high school?",									
													 @"What is your favorite TV program?",
													 @"What is your maternal grandmother's maiden name?",
													nil];
	
	arrGender = [[NSArray alloc] initWithObjects:@"Male",
							@"Female",
							nil];
	
	arrYear = [[NSMutableArray alloc] init];
	for(int i=2001; i>=1960; i--) 
		[arrYear addObject:[NSString stringWithFormat:@"%d",i]];
	
	
	nSecurityQuestionCurrentItem = 0;
	nBirthYearCurrentItem = 0;
	nGenderCurrentItem = 0;
	
	txtSecurityQuestion.text = [arrSecurityQuestions objectAtIndex:nSecurityQuestionCurrentItem];
	txtBirthyear.text = [arrYear objectAtIndex:nBirthYearCurrentItem];
	txtGender.text = [arrGender objectAtIndex:nGenderCurrentItem];
	
}

- (void)viewWillAppear:(BOOL)animated {
	if(APP_DELEGATE.strSelectedCountry != nil)
		txtCountry.text = APP_DELEGATE.strSelectedCountry;
	if(APP_DELEGATE.strSelectedState != nil)
		txtState.text = APP_DELEGATE.strSelectedState;
	if(APP_DELEGATE.strSelectedCity != nil)
		txtCity.text = APP_DELEGATE.strSelectedCity;
}

#pragma mark Get Facebook Methods

- (void)FacebookTapped{
	// If we're not logged in, log in first...
	if (![_session isConnected]) {
		self.loginDialog = nil;
		_loginDialog = [[FBLoginDialog alloc] init];	
		[_loginDialog show];
	}
}	
//- (IBAction)logoutButtonTapped:(id)sender {
//	[_session logout];
//}
//#pragma mark FBSessionDelegate methods

- (void)session:(FBSession*)session didLogin:(FBUID)uid {
	[self getFacebookName];
}

/*- (void)session:(FBSession*)session willLogout:(FBUID)uid {
	_logoutButton.hidden = YES;
	_facebookName = nil;
}
*/
//#pragma mark Get Facebook Name Helper

- (void)getFacebookName {
	FBPermissionDialog* dialog = [[[FBPermissionDialog alloc] init] autorelease];
	dialog.delegate = self;
	dialog.permission = @"email,user_birthday,user_activities,user_interests,user_location,user_likes";
	[dialog show]; 
}

- (void)dialogDidSucceed:(FBDialog*)dialog {
	NSString* fql = [NSString stringWithFormat:
					 @"select uid, name, first_name, last_name, hometown_location, sex, pic_square, current_location, interests, birthday_date , activities, tv, movies, music, books from user where uid == %lld", _session.uid];
	NSLog(@"%@",fql);
	NSDictionary* params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
	NSLog(@"%@",params);
	[[FBRequest requestWithDelegate:self] call:@"facebook.fql.query" params:params];
}

- (void)sessionDidNotLogin:(FBSession*)session {
	[APP_DELEGATE getLocallySavedItems];
	APP_DELEGATE.bLoginFromSavedCredentials = NO;
	QuestionsViewController* _QuestionsViewController = [[QuestionsViewController alloc] initWithNibName:@"QuestionsViewController" bundle:nil];
	[APP_DELEGATE.navController pushViewController:_QuestionsViewController animated:YES];
	[_QuestionsViewController release];	
	NSLog(@"outside");
	
}

//#pragma mark FBRequestDelegate methods

- (void)request:(FBRequest*)request didLoad:(id)result {
	if ([request.method isEqualToString:@"facebook.fql.query"]) {
		NSArray* users = result;
		NSDictionary* user = [users objectAtIndex:0];
		NSLog([user description]);
		NSLog(@"%@",user);
	
		NSString* strURL = @"";
		strURL = [strURL stringByAppendingString:BASE_URL];
		strURL = [strURL stringByAppendingString:@"?action=save_facebook"];
		NSString * encodedURL = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)strURL,NULL,(CFStringRef)@" ",kCFStringEncodingUTF8 );
		
		NSString* blank = @"";
		NSString* strBody = @"";
		if ( [[user valueForKey:@"name"] isEqual: [NSNull null]] ){
			strBody = [strBody stringByAppendingFormat:@"name=%@",blank];
		}
		else{
			strBody = [strBody stringByAppendingFormat:@"name=%@",[user valueForKey:@"name"]];
		}
		if ( [[user valueForKey:@"first_name"] isEqual: [NSNull null]] ){
			strBody = [strBody stringByAppendingFormat:@"&first_name=%@",blank];
		}
		else{
			strBody = [strBody stringByAppendingFormat:@"&first_name=%@",[user valueForKey:@"first_name"]];
		}
		
		if ( [[user valueForKey:@"last_name"] isEqual: [NSNull null]] ){
			strBody = [strBody stringByAppendingFormat:@"&last_name=%@",blank];
		}
		else{
			strBody = [strBody stringByAppendingFormat:@"&last_name=%@",[user valueForKey:@"last_name"]];
		}
		
		if ( [[user valueForKey:@"sex"] isEqual: [NSNull null]] ){
			strBody = [strBody stringByAppendingFormat:@"&sex=%@",blank];
		}
		else{
			strBody = [strBody stringByAppendingFormat:@"&sex=%@",[user valueForKey:@"sex"]];
		}
		
		if ( [[user valueForKey:@"pic_square"] isEqual: [NSNull null]] ){
			strBody = [strBody stringByAppendingFormat:@"&pic_square=%@",blank];
		}
		else{
			strBody = [strBody stringByAppendingFormat:@"&pic_square=%@",[user valueForKey:@"pic_square"]];
		}
		if ( [[[user valueForKey:@"current_location"]  valueForKey:@"city"] isEqual: [NSNull null]] ){
			strBody = [strBody stringByAppendingFormat:@"&city=%@",blank];
		}
		else{
			strBody = [strBody stringByAppendingFormat:@"&city=%@",[[user valueForKey:@"current_location"]  valueForKey:@"city"]] ;
		}
		
		if ( [[[user valueForKey:@"current_location"]  valueForKey:@"state"] isEqual: [NSNull null]] ){
			strBody = [strBody stringByAppendingFormat:@"&state=%@",blank];
		}
		else{
			strBody = [strBody stringByAppendingFormat:@"&state=%@",[[user valueForKey:@"current_location"]  valueForKey:@"state"]];
		}
		
		if ( [[[user valueForKey:@"current_location"]  valueForKey:@"country"] isEqual: [NSNull null]] ){
			strBody = [strBody stringByAppendingFormat:@"&country=%@",blank];
		}
		else{
			strBody = [strBody stringByAppendingFormat:@"&country=%@",[[user valueForKey:@"current_location"]  valueForKey:@"country"]];
		}
		if ([[[user valueForKey:@"current_location"]  valueForKey:@"zip"] isEqual: [NSNull null]] ){
			strBody = [strBody stringByAppendingFormat:@"&zip=%@",blank];
		}
		else{
			strBody = [strBody stringByAppendingFormat:@"&zip=%@",[[user valueForKey:@"current_location"]  valueForKey:@"zip"]];
		}
		
		
		if ( [[user valueForKey:@"interests"] isEqual: [NSNull null]] ){
			strBody = [strBody stringByAppendingFormat:@"&interests=%@",blank];
		}
		else{
			strBody = [strBody stringByAppendingFormat:@"&interests=%@",[user valueForKey:@"interests"]];
		}
		if ( [[user valueForKey:@"birthday_date"] isEqual: [NSNull null]] ){
			strBody = [strBody stringByAppendingFormat:@"&birthday_date=%@",blank];
		}
		else{
			strBody = [strBody stringByAppendingFormat:@"&birthday_date=%@",[user valueForKey:@"birthday_date"]];
		}
		if ( [[user valueForKey:@"activities"] isEqual: [NSNull null]] ){
			strBody = [strBody stringByAppendingFormat:@"&activities=%@",blank];
		}
		else{
			strBody = [strBody stringByAppendingFormat:@"&activities=%@",[user valueForKey:@"activities"]];
		}
		if ( [[user valueForKey:@"tv"] isEqual: [NSNull null]] ){
			strBody = [strBody stringByAppendingFormat:@"&tv=%@",blank];
		}
		else{
			strBody = [strBody stringByAppendingFormat:@"&tv=%@",[user valueForKey:@"tv"]];
		}
		if ( [[user valueForKey:@"movies"] isEqual: [NSNull null]] ){
			strBody = [strBody stringByAppendingFormat:@"&movies=%@",blank];
		}
		else{
			strBody = [strBody stringByAppendingFormat:@"&movies=%@",[user valueForKey:@"movies"]];
		}
		if ( [[user valueForKey:@"music"] isEqual: [NSNull null]] ){
			strBody = [strBody stringByAppendingFormat:@"&music=%@",blank];
		}
		else{
			strBody = [strBody stringByAppendingFormat:@"&music=%@",[user valueForKey:@"music"]];
		}
		if ( [[user valueForKey:@"books"] isEqual: [NSNull null]] ){
			strBody = [strBody stringByAppendingFormat:@"&books=%@",blank];
		}
		else{
			strBody = [strBody stringByAppendingFormat:@"&books=%@",[user valueForKey:@"books"]];
		}
		if ( [[user valueForKey:@"uid"] isEqual: [NSNull null]] ){
			strBody = [strBody stringByAppendingFormat:@"&id=%@",blank];
		}
		else{
			strBody = [strBody stringByAppendingFormat:@"&id=%@",[user valueForKey:@"uid"]];
		}
		NSString* tempStr;
		tempStr = [NSString stringWithFormat:@"%d",APP_DELEGATE.nUserID];
		if ( [tempStr isEqual: [NSNull null]] ){
			strBody = [strBody stringByAppendingFormat:@"&user_id=%@",blank];
		}
		else{
			strBody = [strBody stringByAppendingFormat:@"&user_id=%@",tempStr];
		}
		NSLog(@"%@....",strBody);
		NSString * encodedBody = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)strBody,NULL,(CFStringRef)@" ",kCFStringEncodingUTF8 );
		encodedBody = [encodedBody stringByReplacingOccurrencesOfString:@"'" withString:@"''"];	
		NSData* postData = [encodedBody dataUsingEncoding:NSUTF8StringEncoding];
		NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
		
		
		NSMutableURLRequest *requestSubmit = [[[NSMutableURLRequest alloc] init] autorelease];
		[requestSubmit setURL:[NSURL URLWithString:encodedURL]];
		[requestSubmit setHTTPMethod:@"POST"];
		[requestSubmit setValue:postLength forHTTPHeaderField:@"Content-Length"];
		[requestSubmit setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		[requestSubmit setHTTPBody:postData];
		
		if(theConnection != nil) {
			[theConnection cancel];
			[theConnection release];
			theConnection = nil;
		}
		
		theConnection=[[NSURLConnection alloc] initWithRequest:requestSubmit delegate:self];
		receivedData = [[NSMutableData data] retain];
		
		[_session logout];
		_facebookName = nil;
		
		
	} else if ([request.method isEqualToString:@"facebook.users.setStatus"]) {
		NSString* success = result;
		if ([success isEqualToString:@"1"]) {
		} else {
		}
	} else if ([request.method isEqualToString:@"facebook.photos.upload"]) {
		NSDictionary* photoInfo = result;
		NSString* pid = [photoInfo objectForKey:@"pid"];
	}
	nCurrentWebServiceCall = WEB_SERVICE_CALL_SUBMIT_FACEBOOK;
		

}
#pragma mark Get Validation

-(void)clearDetails {

}

-(BOOL)validateEmail: (NSString *) email {
	NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	BOOL isValid = [emailTest evaluateWithObject:email];
	return isValid;
}

-(void)initLocationItems {
	// Fill temp array of city and state for first country  
	country* tempCountry = [APP_DELEGATE.arrCountry objectAtIndex:0];
	txtCountry.text = tempCountry.strName;
	txtCity.text = @"";
	txtState.text = @"";					
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(alertView.tag == 4000) {
		if (buttonIndex == 1) {
			[self FacebookTapped];
			NSLog(@"inside");
		}
		else if (buttonIndex == 0) {
			NSString* strMessage = @"Please go to Appinion.com to fill your profile.";			
			viewSplash.hidden = NO;
			lblSplash.text = strMessage;			
			[self performSelector:@selector(moveToHome) withObject:nil afterDelay:3];
		}
	}
}

-(void)moveToHome {
	[APP_DELEGATE getLocallySavedItems];
	APP_DELEGATE.bLoginFromSavedCredentials = NO;
	QuestionsViewController* _QuestionsViewController = [[QuestionsViewController alloc] initWithNibName:@"QuestionsViewController" bundle:nil];
	[APP_DELEGATE.navController pushViewController:_QuestionsViewController animated:YES];
	[_QuestionsViewController release];	
}

#pragma mark Button Actions 

-(IBAction)OnButtonSelectCountry:(id)sender {
	SelectCountryViewCountry* _QuestionsViewController = [[SelectCountryViewCountry alloc] initWithNibName:@"SelectCountryViewCountry" bundle:nil];
	[APP_DELEGATE.navController pushViewController:_QuestionsViewController animated:YES];
	[_QuestionsViewController release];	
}

-(IBAction)OnButtonBack:(id)sender {
	[APP_DELEGATE.navController popViewControllerAnimated:YES];
}

-(IBAction)OnButtonHome:(id)sender {

}
-(IBAction)OnButtonNext:(id)sender{
	if(APP_DELEGATE.netStatus == NotReachable) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Internet connection is not available. Please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		[[ActivityIndicator sharedActivityIndicator] hide];
		return;
	}
	if([txtEmail.text length] < 1 ) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Please enter account email" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if([txtPassword.text length] < 1 ) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Please enter account password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if([txtVerifyPassword.text length] < 1 ) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Please enter account verify password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if([txtSecurityAnswer.text length] < 1 ) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Please enter account answer" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
	if([txtSecurityQuestion.text length] < 1 || nSecurityQuestionCurrentItem < 1) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Please enter account question" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	bIsStep1 = NO;
	btnNext.hidden = YES;
	btnSubmit.hidden = NO;
	viewStep2.hidden = NO;
	[lblStep2 setFont:[UIFont boldSystemFontOfSize:14]];
	lblStep2.textColor = [UIColor blackColor];
	[lblStep1 setFont:[UIFont systemFontOfSize:14]];
	lblStep1.textColor = [UIColor grayColor];	
	
	btnSubmit = [UIButton buttonWithType:UIButtonTypeCustom];
	btnSubmit.frame = CGRectMake(250, 6, 62, 33);
	[btnSubmit setImage:[UIImage imageNamed:@"submit.png"] forState:UIControlStateNormal];
	[btnSubmit addTarget:self action:@selector(OnButtonSubmit:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btnSubmit];
	//[self OnButtonStep2:nil];
	//[self.view addSubview:viewStep2];
}	
-(IBAction)OnButtonSubmit:(id)sender {
	if([txtFirstName.text length] < 1 ) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Please enter first name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if([txtZipcode.text length] < 1 ) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Please enter zip code" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	NSString* strTrimmedPassword = [txtPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSString* strTrimmedVerifyPassword = [txtVerifyPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if(![strTrimmedPassword isEqualToString:strTrimmedVerifyPassword]){
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Please enter same account password and varify password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	[[ActivityIndicator sharedActivityIndicator] show];
	
	nCurrentWebServiceCall = WEB_SERVICE_CALL_SUBMIT;
	
	NSString* strURL = @"";
	strURL = [strURL stringByAppendingString:BASE_URL];
	strURL = [strURL stringByAppendingString:@"?action=signup"];
	NSString * encodedURL = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)strURL,NULL,(CFStringRef)@" ",kCFStringEncodingUTF8 );
	
	NSString* strBody = @"";
	strBody = [strBody stringByAppendingFormat:@"email=%@",[txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	strBody = [strBody stringByAppendingFormat:@"&password=%@",[txtPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	strBody = [strBody stringByAppendingFormat:@"&security_question=%@",[txtSecurityQuestion.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	strBody = [strBody stringByAppendingFormat:@"&security_answer=%@",[txtSecurityAnswer.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	strBody = [strBody stringByAppendingFormat:@"&first_name=%@",[txtFirstName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	strBody = [strBody stringByAppendingFormat:@"&zipcode=%@",[txtZipcode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	strBody = [strBody stringByAppendingFormat:@"&birth_date=%@",[txtBirthyear.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	NSString* strGender;
	if(nGenderCurrentItem == 0)
		strGender = @"M";
	else
		strGender = @"F";
	strBody = [strBody stringByAppendingFormat:@"&gender=%@",strGender];
	if([APP_DELEGATE._deviceToken length] > 0)
		strURL = [strURL stringByAppendingFormat:@"&deviceid=%@",APP_DELEGATE._deviceToken];
	else
		strURL = [strURL stringByAppendingString:@"&deviceid="];		
	NSString * encodedBody = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)strBody,NULL,(CFStringRef)@" ",kCFStringEncodingUTF8 );
	encodedBody = [encodedBody stringByReplacingOccurrencesOfString:@"'" withString:@"''"];	
	NSData* postData = [encodedBody dataUsingEncoding:NSUTF8StringEncoding];
	NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:encodedURL]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
	if(theConnection != nil) {
		[theConnection cancel];
		[theConnection release];
		theConnection = nil;
	}
	
	theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
	receivedData = [[NSMutableData data] retain];

}

-(IBAction)OnButtonStep2:(id)sender {
	bIsStep1 = NO;
	viewStep1.hidden = YES;
	viewStep2.hidden = NO;
	btnNext.hidden = YES;
	btnSubmit.hidden = NO;
	[lblStep2 setFont:[UIFont boldSystemFontOfSize:14]];
	lblStep2.textColor = [UIColor blackColor];
	[lblStep1 setFont:[UIFont systemFontOfSize:14]];
	lblStep1.textColor = [UIColor grayColor];	
}

-(IBAction)OnButtonStep1:(id)sender {
	bIsStep1 = YES;
	viewStep2.hidden = YES;
	viewStep1.hidden = NO;
	btnNext.hidden = NO;
	btnSubmit.hidden = YES;
	[lblStep1 setFont:[UIFont boldSystemFontOfSize:14]];
	lblStep1.textColor = [UIColor blackColor];
	[lblStep2 setFont:[UIFont systemFontOfSize:14]];
	lblStep2.textColor = [UIColor grayColor];
}

-(IBAction)OnButtonInfo:(id)sender {
	InfoViewController* _InfoViewController = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
	[APP_DELEGATE.navController pushViewController:_InfoViewController animated:YES];
	[_InfoViewController release];
}

-(IBAction)OnButtonPickerDone:(id)sender {
	if(bIsViewMovedUp) {
		[UIView beginAnimations:nil context:NULL]; 
		[UIView setAnimationDuration:0.50]; 
		bIsViewMovedUp = NO;
		CGRect viewFrame = viewMain.frame;
		viewFrame.origin.y = 45;
		viewMain.frame = viewFrame;	
		[UIView commitAnimations]; 
	}
	
	
	viewStep1.userInteractionEnabled = YES;
	viewStep2.userInteractionEnabled = YES;
	pickerToolbar.hidden = YES;
	picker.hidden = YES;
}

#pragma mark WEB_SERVICE delegates
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

	if(nCurrentWebServiceCall == WEB_SERVICE_CALL_COUNTRY_LIST) {
		NSString* strResponse = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
		[receivedData release];
		
		if(APP_DELEGATE.arrCountry == nil) {
			SBJSON* json = [[SBJSON alloc] init];
			NSError* error = nil;
			NSDictionary *results = [json objectWithString:strResponse error:&error];		
			
			NSArray* arrItems = [results objectForKey:@"appinion"];
			NSDictionary* dictCountryCount = [arrItems objectAtIndex:[arrItems count]-3];
			NSDictionary* dictStateCount = [arrItems objectAtIndex:[arrItems count]-2];
			NSDictionary* dictCityCount = [arrItems objectAtIndex:[arrItems count]-1];
			int nCountryCount = [[dictCountryCount valueForKey:@"country_count"] integerValue];
			int nStateCount = [[dictStateCount valueForKey:@"state_count"] integerValue];
			int nCityCount = [[dictCityCount valueForKey:@"city_count"] integerValue];
			
			APP_DELEGATE.arrCountry = [[NSMutableArray alloc] init];
			APP_DELEGATE.arrState = [[NSMutableArray alloc] init];
			APP_DELEGATE.arrCity = [[NSMutableArray alloc] init];
			
			NSString* strTemp = @"";
			NSDictionary* dictTemp;
			NSDictionary* dictTempDetail;
			for(int i=0; i<nCountryCount; i++) {
				strTemp = [NSString stringWithFormat:@"country%d",i];
				dictTemp = [arrItems objectAtIndex:i];
				dictTempDetail = [dictTemp valueForKey:strTemp];
				country* temp = [[country alloc] init];
				temp.strID = [dictTempDetail objectForKey:@"countryId"];
				temp.strName = [dictTempDetail objectForKey:@"countryName"];
				[APP_DELEGATE.arrCountry addObject:temp];
				[temp release];
			}
			for(int i=nCountryCount; i<nStateCount+nCountryCount; i++) {
				strTemp = [NSString stringWithFormat:@"state%d",i-nCountryCount];
				dictTemp = [arrItems objectAtIndex:i];
				dictTempDetail = [dictTemp valueForKey:strTemp];
				state* temp = [[state alloc] init];
				temp.strCountryID = [dictTempDetail objectForKey:@"countryId"];
				temp.strStateID = [dictTempDetail objectForKey:@"stateId"];
				temp.strStateCode = [dictTempDetail objectForKey:@"stateCode"];
				temp.strName = [dictTempDetail objectForKey:@"stateName"];
				[APP_DELEGATE.arrState addObject:temp];
				[temp release];
			}
			for(int i=nCountryCount+nStateCount; i<nCityCount+nStateCount+nCountryCount; i++) {
				strTemp = [NSString stringWithFormat:@"city%d",i-nCountryCount-nStateCount];
				dictTemp = [arrItems objectAtIndex:i];
				dictTempDetail = [dictTemp valueForKey:strTemp];
				city* temp = [[city alloc] init];
				temp.strStateCode = [dictTempDetail objectForKey:@"stateCode"];
				temp.strName = [dictTempDetail objectForKey:@"city_text"];
				[APP_DELEGATE.arrCity addObject:temp];
				[temp release];
			}

			[self initLocationItems];
			[[ActivityIndicator sharedActivityIndicator] hide];
			
		}	
	}
	else if(nCurrentWebServiceCall == WEB_SERVICE_CALL_SUBMIT) {
		[[ActivityIndicator sharedActivityIndicator] hide];
		NSString* strResponse = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
		NSLog(@"=======Signup Response======\n%@",strResponse);
		[receivedData release];
		SBJSON* json = [[SBJSON alloc] init];
		NSError* error = nil;
		NSDictionary *results = [json objectWithString:strResponse error:&error];		
		NSArray* arrItems = [results objectForKey:@"appinion"];
		NSDictionary *firstItem = [arrItems objectAtIndex:0];
		NSString* strMessage = [firstItem valueForKey:@"message"];
		if([strMessage isEqualToString:@"Registration Completed"]){
			for(UIViewController* vc in APP_DELEGATE.navController.viewControllers) {	
				if([vc.nibName isEqualToString:@"HomeViewController"]) {
					HomeViewController* homeVC = (HomeViewController*)vc;
					[homeVC.btnLogin setTitle:@"Logout" forState:UIControlStateNormal];
				}		
			}			
			APP_DELEGATE.nUserID = [[firstItem valueForKey:@"user_id"] integerValue];
			APP_DELEGATE.bIsUserLoggedIn = YES;
			NSLog(@"user id %d",APP_DELEGATE.nUserID);
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Thanks for registering with Appinion! Do you want to connect your interests via Facebook?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
			alert.tag = 4000;
			[alert show];
			[alert release];	
		}
		else {
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:strMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];	
		}
	}
	else if(nCurrentWebServiceCall == WEB_SERVICE_CALL_SUBMIT_FACEBOOK) {
		[[ActivityIndicator sharedActivityIndicator] hide];
		NSString* strResponse = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
		NSLog(@"=======FaceBook Response======\n%@",strResponse);
		[receivedData release];
		SBJSON* json = [[SBJSON alloc] init];
		NSError* error = nil;

		NSDictionary *results = [json objectWithString:strResponse error:&error];		
		NSLog(@"%@", error);

		NSArray* arrItems = [results objectForKey:@"appinion"];
		NSLog(@"%@",arrItems);
		NSDictionary *firstItem = [arrItems objectAtIndex:0];
		NSString* strMessage = [firstItem valueForKey:@"message"];
		NSLog(@"%@",firstItem);
		NSLog(@"%@",strMessage);
		
		if([strMessage isEqualToString:@"success"]){
			for(UIViewController* vc in APP_DELEGATE.navController.viewControllers) {	
				if([vc.nibName isEqualToString:@"HomeViewController"]) {
					HomeViewController* homeVC = (HomeViewController*)vc;
					[homeVC.btnLogin setTitle:@"Logout" forState:UIControlStateNormal];
				}		
			}			
			[APP_DELEGATE getLocallySavedItems];
			APP_DELEGATE.bLoginFromSavedCredentials = NO;
			QuestionsViewController* _QuestionsViewController = [[QuestionsViewController alloc] initWithNibName:@"QuestionsViewController" bundle:nil];
			[APP_DELEGATE.navController pushViewController:_QuestionsViewController animated:YES];
			[_QuestionsViewController release];	
		}
		else if([strMessage isEqualToString:@"This facebook account has been already used please try another!"]){
			strMessage = @"This facebook account has been already used. Please go to Appinion.com to fill your profile.";			
			viewSplash.hidden = NO;
			lblSplash.text = strMessage;
		}
		else {
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:strMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];	
		}
	}
}

#pragma mark Tex Field delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	
	if(textField.tag == TEXT_FIELD_STATE ||
 	   textField.tag == TEXT_FIELD_COUNTRY ||
 	   textField.tag == TEXT_FIELD_CITY)
		return NO;
		
	CGRect temp = textField.frame;
	NSLog(@"frame %f %f %f %f",temp.origin.x,temp.origin.y,temp.size.width,temp.size.height);

	if(textField.tag == TEXT_FIELD_SECURITY_QUESTION  ||
 	   textField.tag == TEXT_FIELD_BIRTH_YEAR ||
 	   textField.tag == TEXT_FIELD_GENDER)
	{ 
		[currentTextField resignFirstResponder];
		[UIView beginAnimations:nil context:NULL]; 
		[UIView setAnimationDuration:0.50]; 
		bIsViewMovedUp = YES;
		CGRect viewFrame = viewMain.frame;
		if(temp.origin.y > 170)
			viewFrame.origin.y = -50;
		else {
			viewFrame.origin.y = -40;
		}
		viewMain.frame = viewFrame;
		[UIView commitAnimations]; 
		
		[self.view bringSubviewToFront:pickerToolbar];
		[self.view bringSubviewToFront:picker];
		
		viewStep1.userInteractionEnabled = NO;
		viewStep2.userInteractionEnabled = NO;
		nCurrentPickerIndex = textField.tag;
		pickerToolbar.hidden = NO;
		picker.hidden = NO;
		[picker reloadAllComponents];
		
		// set existing item in picker
		if(nCurrentPickerIndex == TEXT_FIELD_SECURITY_QUESTION) {
			if(nSecurityQuestionCurrentItem >= 0)
				[picker selectRow:nSecurityQuestionCurrentItem inComponent:0 animated:YES];
			else
				[picker selectRow:0 inComponent:0 animated:YES];
		}
		if(nCurrentPickerIndex == TEXT_FIELD_GENDER) {
			if(nGenderCurrentItem >= 0)
				[picker selectRow:nGenderCurrentItem inComponent:0 animated:YES];
			else
				[picker selectRow:0 inComponent:0 animated:YES];			
		}
		if(nCurrentPickerIndex == TEXT_FIELD_BIRTH_YEAR) {
			if(nBirthYearCurrentItem >= 0)
				[picker selectRow:nBirthYearCurrentItem inComponent:0 animated:YES];
			else
				[picker selectRow:0 inComponent:0 animated:YES];			
		}	
		[picker reloadAllComponents];

		return NO;
	} 		
	else {
		currentTextField = textField;
		if(temp.origin.y > 158) {		
			[UIView beginAnimations:nil context:NULL]; 
			[UIView setAnimationDuration:0.50]; 
			bIsViewMovedUp = YES;
			CGRect viewFrame = viewMain.frame;
			if(temp.origin.y > 230)
				viewFrame.origin.y = -60;
			else
				viewFrame.origin.y = -20;
			viewMain.frame = viewFrame;
			[UIView commitAnimations]; 
		}
		return YES;
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	if(bIsViewMovedUp) {
		[UIView beginAnimations:nil context:NULL]; 
		[UIView setAnimationDuration:0.50]; 
		bIsViewMovedUp = NO;
		CGRect viewFrame = viewMain.frame;
		viewFrame.origin.y = 45;
		viewMain.frame = viewFrame;	
		[UIView commitAnimations]; 
	}
	return YES;
}

#pragma mark picker view delegates

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component { 	
	int nRow = 0;
	
	if(nCurrentPickerIndex == TEXT_FIELD_SECURITY_QUESTION)
		nRow = [arrSecurityQuestions count];
	else if(nCurrentPickerIndex == TEXT_FIELD_BIRTH_YEAR)
		nRow = [arrYear count];
	else if(nCurrentPickerIndex == TEXT_FIELD_GENDER)
		nRow = [arrGender count];
	else if(nCurrentPickerIndex == TEXT_FIELD_COUNTRY) {
		nRow = [APP_DELEGATE.arrCountry count];
	}
	else if(nCurrentPickerIndex == TEXT_FIELD_STATE) {
		nRow = [arrTempState count];
	}
	else if(nCurrentPickerIndex == TEXT_FIELD_CITY) {
		nRow = [arrTempCity count];
	}
	
	return nRow;
}
	

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 30)];
	NSString* strVal = @"";
	if(nCurrentPickerIndex == TEXT_FIELD_SECURITY_QUESTION) {
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont boldSystemFontOfSize:12];
		label.text = [arrSecurityQuestions objectAtIndex:row];
	}
	if(nCurrentPickerIndex == TEXT_FIELD_BIRTH_YEAR) {		
		strVal = [arrYear objectAtIndex:row];
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont boldSystemFontOfSize:17];
		label.text = strVal;		
	}	
	if(nCurrentPickerIndex == TEXT_FIELD_GENDER) {
		strVal = [arrGender objectAtIndex:row];	
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont boldSystemFontOfSize:17];
		label.text = strVal;				
	}
	if(nCurrentPickerIndex == TEXT_FIELD_COUNTRY) {
		country* temp = [APP_DELEGATE.arrCountry objectAtIndex:row];
		strVal = temp.strName;
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont boldSystemFontOfSize:17];
		label.text = strVal;		
	}	
	if(nCurrentPickerIndex == TEXT_FIELD_STATE) {
		state* temp = [arrTempState objectAtIndex:row];
		strVal = temp.strName;
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont boldSystemFontOfSize:17];
		label.text = strVal;				
	}	
	if(nCurrentPickerIndex == TEXT_FIELD_CITY) {
		city* temp = [arrTempCity objectAtIndex:row];
		strVal = temp.strName;
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont boldSystemFontOfSize:17];
		label.text = strVal;				
	}			
	return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	if(nCurrentPickerIndex == TEXT_FIELD_SECURITY_QUESTION) {
		nSecurityQuestionCurrentItem = row;
		txtSecurityQuestion.text = [arrSecurityQuestions objectAtIndex:row];	
	}
	else if(nCurrentPickerIndex == TEXT_FIELD_BIRTH_YEAR) {
		nBirthYearCurrentItem = row;
		txtBirthyear.text =  [arrYear objectAtIndex:row];
	}	
	else if(nCurrentPickerIndex == TEXT_FIELD_GENDER) {
		nGenderCurrentItem = row;
		txtGender.text = [arrGender objectAtIndex:row];
	}
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	[currentElementValue release];
	[arrSecurityQuestions release];
	[arrGender release];
	[_session release];
	_session = nil;
    [_loginDialog release];
	_loginDialog = nil;
    [_facebookName release];
	_facebookName = nil;
	
}


@end
