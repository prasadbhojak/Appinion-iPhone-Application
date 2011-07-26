//
//  HomeViewController.m
//  Appinion
//
//  Created by admin on 01/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HomeViewController.h"


@implementation HomeViewController
@synthesize btnLogin;
@synthesize lblQuestionCount,BtnMessageME;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    [super viewDidLoad];
}


-(IBAction)MessageMe:(id)sender
{
	UIActionSheet *actionSheet =
	[[UIActionSheet alloc] initWithTitle:@"Invite a friend, get an app"
								delegate:self
					    cancelButtonTitle:@"Cancel"
						destructiveButtonTitle:nil
					    otherButtonTitles:@"Email", @"SMS",nil];
	[actionSheet showInView:self.view];
	[actionSheet release];
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods
-(void)CreateLinkForMail{
	[[ActivityIndicator sharedActivityIndicator] show];
	nCurrentWebServiceCall = WEB_SERVICE_CALL_GET_INVITE;
	
	int r = arc4random() % 5000000;
	randomKey = [NSString stringWithFormat:@"%d",r];
	[randomKey retain];
	NSLog(@"random Key  %@",randomKey);
	NSString* strURL = @"";
	strURL = [strURL stringByAppendingString:BASE_URL];
	strURL = [strURL stringByAppendingString:@"?action=invite"];
	strURL = [strURL stringByAppendingFormat:@"&view=user&user_id=%d&key=%@",APP_DELEGATE.nUserID,randomKey];		
	if(buttonClicked == 0)
		strURL = [strURL stringByAppendingString:@"&type=email"];
	else if(buttonClicked == 1)
		strURL = [strURL stringByAppendingString:@"&type=SMS"];		
	
	[strURL retain];
	
	NSLog(@"URl ....%@",strURL);
	
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
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	buttonClicked = buttonIndex;
	if (buttonClicked == 0)
	{
		[self CreateLinkForMail];
				
	}
	else if (buttonClicked == 1)
	{
		[self CreateLinkForMail];
	}
	
} 
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self becomeFirstResponder];
	
	switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:{ 
			NSLog(@"Message sent");
			break;
		}
		case MFMailComposeResultFailed:{
			UIAlertView *alert = [[UIAlertView alloc] 
								  initWithTitle:@"Appinion" 
								  message:@"Failed to send an email"
								  delegate:self cancelButtonTitle:@"OK" 
								  otherButtonTitles: nil];
			[alert show];
			[alert release];
			break;
		}
		default:
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark EMail methods


#pragma mark -
#pragma mark SMS methods
-(void)showSMSPicker{//:(NSString*)user_id Key:(NSString*)keyText{
	Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
//	UILabel* message;
//	message = [[UILabel alloc] init];
//	message.frame = CGRectMake(70, 220, 100, 50);
	
	if (messageClass != nil) { 			
		// Check whether the current device is configured for sending SMS messages
		if ([messageClass canSendText]) {
			[self displaySMSComposerSheet];
		}
		else {	
			NSLog(@"Device not configured to send SMS.");
			//message.hidden = NO;
//			message.text = @"Device not configured to send SMS.";
		}
	}
	else {
		NSLog(@"Device not configured to send SMS.");

//		message.hidden = NO;
//		message.text = @"Device not configured to send SMS.";
	}
}

// Displays an SMS composition interface inside the application. 
-(void)displaySMSComposerSheet 
{
	MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
	picker.messageComposeDelegate = self;
	
	//NSString* strURL = @"";
//	strURL = [strURL stringByAppendingString:BASE_URL];
//	strURL = [strURL stringByAppendingString:@"?option=com_signup"];
//	NSLog(@"%@",strURL);
//	strURL = [strURL stringByAppendingFormat:@"&view=user&id=%d&key=%@",APP_DELEGATE.nUserID,randomKey];		
//	[strURL retain];
//	NSString *SmsBody = strURL;
	

	picker.body = strMessageBody;
	
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

// Dismisses the message composition interface when users tap Cancel or Send. Proceeds to update the 
// feedback message field with the result of the operation.
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	
//	UILabel* message;
//	message.frame = CGRectMake(70, 220, 100, 50);
//	message.hidden = NO;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MessageComposeResultCancelled:
//			message.text = @"Result: SMS sending canceled";
			break;
		case MessageComposeResultSent:
//			message.text = @"Result: SMS sent";
			break;
		case MessageComposeResultFailed:
//			message.text = @"Result: SMS sending failed";
			break;
		default:
//			message.text = @"Result: SMS not sent";
		{
			UIAlertView *alert = [[UIAlertView alloc] 
								  initWithTitle:@"Email" 
								  message:@"Sending Failed – Unknown Error  "
								  delegate:self cancelButtonTitle:@"OK" 
								  otherButtonTitles: nil];
			[alert show];
			[alert release];
		}
			
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)viewWillAppear:(BOOL)animated {
	//[self performSelector:@selector(animateTransition:) withObject:[NSNumber numberWithFloat: TIME_FOR_SHRINKING]];
	
	if(APP_DELEGATE.nUserID > -1) {
		[btnLogin setTitle:@"Logout" forState:UIControlStateNormal];
	}
	else {
		[btnLogin setTitle:@"Login" forState:UIControlStateNormal];
	}	
	
	if(APP_DELEGATE.netStatus == NotReachable ) { //Test
		NSLog(@"Question count = %@",[APP_DELEGATE getLocallySavedQuestionCount]);
		lblQuestionCount.text = @"";
		lblCreditCount.text = @"";
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Internet connection is not available. Please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;		
	}	
	else if(APP_DELEGATE.bIsUserLoggedIn) {
			[[ActivityIndicator sharedActivityIndicator] show];
			nCurrentWebServiceCall = WEB_SERVICE_CALL_GET_TOTAL_CREDIT_COUNT;
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
}

- (void)viewWillDisappear:(BOOL)animated {
	lblCreditCount.text = @"";
	lblQuestionCount.text = @"";
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
	
	NSString* strResponse = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	[receivedData release];

	if(nCurrentWebServiceCall == WEB_SERVICE_CALL_GET_TOTAL_CREDIT_COUNT) { 
		SBJSON *json = [[SBJSON alloc] init];
		NSError *error = nil;
		NSDictionary *results = [json objectWithString:strResponse error:&error];		
		NSArray* arrItems = [results objectForKey:@"appinion"];
		NSDictionary* firstItem = [arrItems objectAtIndex:0];
		//lblCreditCount.text  = [firstItem objectForKey:@"credit_points"];
		[APP_DELEGATE saveCreditCountLocally:[firstItem objectForKey:@"credit_points"]];
		nCurrentWebServiceCall = WEB_SERVICE_CALL_GET_QUESTION_COUNT;
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
	else if(nCurrentWebServiceCall == WEB_SERVICE_CALL_GET_QUESTION_COUNT) {
		SBJSON *json = [[SBJSON alloc] init];
		NSError *error = nil;
		//NSLog(strResponse);
		NSDictionary *results = [json objectWithString:strResponse error:&error];		
		NSArray* arrItems = [results objectForKey:@"appinion"];
		NSDictionary* firstItem = [arrItems objectAtIndex:0];		
		//lblQuestionCount.text = [NSString stringWithFormat:@"%d",[[firstItem objectForKey:@"total_question"] integerValue]];
		NSLog(@"Question count %d",[[firstItem objectForKey:@"total_question"] integerValue]);
		[APP_DELEGATE saveQuestionCountLocally:[NSString stringWithFormat:@"%d",[[firstItem objectForKey:@"total_question"] integerValue]]];
		
		lblQuestionCount.text = [APP_DELEGATE getLocallySavedQuestionCount];
		lblCreditCount.text = [APP_DELEGATE getLocallySavedCreditCount];
		
		[[ActivityIndicator sharedActivityIndicator] hide];	
	}
	else if(nCurrentWebServiceCall == WEB_SERVICE_CALL_GET_INVITE){
		[[ActivityIndicator sharedActivityIndicator] hide];
		NSLog(@"=======FaceBook Response======\n%@",strResponse);
		SBJSON* json = [[SBJSON alloc] init];
		NSError* error = nil;
		
		NSDictionary *results = [json objectWithString:strResponse error:&error];		
		NSLog(@"%@", error);
		
		NSArray* arrItems = [results objectForKey:@"appinion"];
		//NSLog(@"%@",arrItems);
		NSDictionary *firstItem = [arrItems objectAtIndex:0];
		strMessageSubjet = [firstItem valueForKey:@"subject"];
		strMessageBody = [firstItem valueForKey:@"message"];
		NSLog(@"Subject message",strMessageSubjet);
		NSLog(@"Message Body",strMessageBody);
		
		if (buttonClicked == 0) {
			if ([MFMailComposeViewController canSendMail]){
				MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
				controller.mailComposeDelegate = self;
				[controller setSubject:strMessageSubjet];
				[controller setMessageBody:strMessageBody isHTML:YES];
				[self presentModalViewController:controller animated:YES];
				[controller release];
			}
			else{
				
			}
		}
		else {
			[self showSMSPicker];//:User_ID Key:randomKey];
			//[self showSMSPicker];
		}
		
	/*	NSString* User_ID = [NSString stringWithFormat:@"%d",APP_DELEGATE.nUserID];
	//	NSString* KeyStr = randomKey;
	//	NSLog(<#NSString *format#>)
		if([strMessage isEqualToString:@"success"]){
			if (buttonClicked == 0) {
			[self displayMailComposerSheet:User_ID Key:randomKey];
			}
			else {
				[self showSMSPicker:User_ID Key:randomKey];
				//[self showSMSPicker];
			}

		}
		else {
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:strMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];	
		}*/
	}
	
	
}
-(IBAction)OnButtonQestions:(id)sender {
	

	//_QuestionsViewController.view.hidden = YES; 
	if(APP_DELEGATE.netStatus == NotReachable) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Internet connection is not available. Please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		return;
	}	
	if(APP_DELEGATE.nUserID<=0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Please login to go to Question screen" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}else {
		_QuestionsViewController = [[QuestionsViewController alloc] initWithNibName:@"QuestionsViewController" bundle:nil];
		[APP_DELEGATE.navController pushViewController:_QuestionsViewController animated:NO];
		[_QuestionsViewController release];
	}	
}
//- (void)doPopInAnimationWithDelegate{ 
//	CALayer *viewLayer = self.view.layer;
//	CAKeyframeAnimation* popInAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"]; 
//	popInAnimation.duration = 1.0; 
//	popInAnimation.values = [NSArray arrayWithObjects: [NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:.9], [NSNumber numberWithFloat:1], nil]; 
//	//popInAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.4], [NSNumber numberWithFloat:0.8], [NSNumber numberWithFloat:1.0], nil]; 
//	[viewLayer addAnimation:popInAnimation forKey:@"transform.scale"]; 
//}
-(IBAction)OnButtonCredit:(id)sender {
	
	if(APP_DELEGATE.netStatus == NotReachable) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Internet connection is not available. Please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		return;
	}
	if(APP_DELEGATE.nUserID<=0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Please login to go to Credit payout screen" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}else {
		//[[ActivityIndicator sharedActivityIndicator] show];
		NSLog(@"user id   %d",APP_DELEGATE.nUserID);
		TopPaidAndPromotedViewController* _TopPaidAndPromotedViewController = [[TopPaidAndPromotedViewController alloc] initWithNibName:@"TopPaidAndPromotedViewController" bundle:nil];
		_TopPaidAndPromotedViewController.isTopPaidFlag = TRUE;		
		[APP_DELEGATE.navController pushViewController:_TopPaidAndPromotedViewController  animated:NO];
		[_TopPaidAndPromotedViewController release];	
	}	
}

-(IBAction)OnButtonLogin:(id)sender {
	if(!APP_DELEGATE.bIsUserLoggedIn) {
		LoginViewController* _LoginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
		[APP_DELEGATE.navController pushViewController:_LoginViewController animated:YES];
		[_LoginViewController release];
	}
	else {
		APP_DELEGATE.bIsUserLoggedIn = NO;
		APP_DELEGATE.nUserID = -1;
		LoginViewController* _LoginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
		[APP_DELEGATE.navController pushViewController:_LoginViewController animated:YES];
		[_LoginViewController release];
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
}


@end
