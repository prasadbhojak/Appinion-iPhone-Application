//
//  QuestionsViewController.m
//  Appinion
//
//  Created by Sunil Adhyaru on 06/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QuestionsViewController.h"

@implementation QuestionsViewController
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
	 [super viewDidLoad];
	 
	 
	 nSelectedAnswer = -1;
	 nCurrentQuestionNumber = 1;

	 btnBrand.hidden = YES;
	 imgViewBrandBack.hidden = YES;
	 
	 if(!APP_DELEGATE.bLoginFromSavedCredentials) {
		 if(APP_DELEGATE.netStatus == NotReachable) { //Test
			 UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Internet connection is not available. Please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			 [alert show];
			 [alert release];
		 }
		 else {
			 [[ActivityIndicator sharedActivityIndicator] show];
			 [self postDeviceID];	 
		 }
	 }
	 else {
		 APP_DELEGATE.bLoginFromSavedCredentials = NO;
	 }

 }


- (void)viewWillAppear:(BOOL)animated {
	animationView.alpha = 0;
	animationView.transform = CGAffineTransformMakeScale(0.2,0.2);
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.4];
	animationView.transform = CGAffineTransformMakeScale(1.0,1.0);
	animationView.alpha = 1;	
	[UIView commitAnimations];
}



+(UIImage *) resizeImage:(UIImage *)orginalImage resizeSize:(CGSize)size
{
	CGFloat actualHeight = orginalImage.size.height;
	CGFloat actualWidth = orginalImage.size.width;
	if(actualWidth <= size.width && actualHeight<=size.height)
	{
		return orginalImage;
	}
	float oldRatio = actualWidth/actualHeight;
	float newRatio = size.width/size.height;
	if(oldRatio < newRatio)
	{
		oldRatio = size.height/actualHeight;
		actualWidth = oldRatio * actualWidth;
		actualHeight = size.height;
	}
	else 
	{
		oldRatio = size.width/actualWidth;
		actualHeight = oldRatio * actualHeight;
		actualWidth = size.width;
	}
	CGRect rect = CGRectMake(0.0,0.0,actualWidth,actualHeight);
	UIGraphicsBeginImageContext(rect.size);
	[orginalImage drawInRect:rect];
	orginalImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return orginalImage;
}

-(void)postDeviceID {
	nCurrentWebserviceCall = WEB_SERVICE_CALL_POST_DEVICE_ID;
	
	NSString* strURL = @"";
	strURL = [strURL stringByAppendingString:BASE_URL];
	strURL = [strURL stringByAppendingString:@"?action=savedeviceid"];
	NSString * encodedURL = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)strURL,NULL,(CFStringRef)@" ",kCFStringEncodingUTF8 );
	
	NSString* strBody = @"";
	strBody = [strBody stringByAppendingFormat:@"deviceid=%@",APP_DELEGATE._deviceToken];
	strBody = [strBody stringByAppendingFormat:@"&user_id=%d",APP_DELEGATE.nUserID];
	NSString * encodedBody = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)strBody,NULL,(CFStringRef)@" ",kCFStringEncodingUTF8 );
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

-(void)postUnpostedAnswer {
	
	NSLog(@"===========================");
	NSLog(@"Unposted question array count %d",[APP_DELEGATE.arrUnpostedAnswers count]);
	NSLog(@"===========================");
	
		Answer* tempAnswer = [APP_DELEGATE.arrUnpostedAnswers objectAtIndex:0];
	
		nCurrentWebserviceCall = WEB_SERVICE_CALL_POST_UNPOSTED_ANSWER;
		NSString* strURL = @"";
		strURL = [strURL stringByAppendingString:BASE_URL];
		strURL = [strURL stringByAppendingString:@"?action=save"];
		NSString * encodedURL = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)strURL,NULL,(CFStringRef)@" ",kCFStringEncodingUTF8 );
		
		NSString* strBody = @"";
		strBody = [strBody stringByAppendingFormat:@"question_id=%@",tempAnswer.strQuestionsID];
		if(![tempAnswer.strSubmitted isEqualToString:@"YES"]) // skip
			strBody = [strBody stringByAppendingFormat:@"&answer="];
		else					// submit
			strBody =  [strBody stringByAppendingFormat:@"&answer=%@",tempAnswer.strAnswerText];
		strBody = [strBody stringByAppendingFormat:@"&user_id=%@",tempAnswer.strUsersID];
		strBody = [strBody stringByReplacingOccurrencesOfString:@"'" withString:@"''"];	
		//NSString* strEscapedString = (NSString *)CFURLCreateStringByAddingPercentEscapes( NULL, (CFStringRef)strBody, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8 );
		//NSLog(strEscapedString);
		NSData* postData = [strBody dataUsingEncoding:NSUTF8StringEncoding];
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

-(void)getQuestion {
	
	if(bShowIntroScreen)
		viewIntro.hidden = NO;
	
	if(APP_DELEGATE.netStatus == NotReachable) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Please connect to internet to get more questions" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		[[ActivityIndicator sharedActivityIndicator] hide];
		
		// Remove all controls from queston screens as no question
		[self clearQuestionScreen];
		viewIntro.hidden = YES;
		return;
	}
	
	[[ActivityIndicator sharedActivityIndicator] show];

	NSString* strURL = @"";
	strURL = [strURL stringByAppendingString:BASE_URL];
	strURL = [strURL stringByAppendingString:@"?action=get_question_data"];
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

-(void)moveToNextQuestion {
	[self showNextQuestion];
}

-(void)showNextQuestion {
	if(APP_DELEGATE.netStatus == NotReachable) {	//Test
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Internet connection is not available. Please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;		
	}
	else {
		
			nCurrentWebserviceCall = WEB_SERVICE_CALL_GET_QUESTION;			
			nSelectedAnswer = -1;
			// deselect all the answers
			for(int i=0; i<nNoOfAnswers; i++) {
				UIImageView* imgView = (UIImageView*)[scrAnswers viewWithTag:i+3001];
				imgView.image = [UIImage imageNamed:@"bg_answer.png"];
			}			
			
			// Get new question if new user login via signup or buffer is empty
			NSLog(@"===========================");
			NSLog(@"Current Question Index %d",APP_DELEGATE.nCurrentQuestionIndex);
			NSLog(@"Question Array Count %d",[APP_DELEGATE.arrQuestions count]);
			NSLog(@"===========================");
			
			if(([APP_DELEGATE.arrQuestions count] == APP_DELEGATE.nCurrentQuestionIndex) || [APP_DELEGATE.arrQuestions count] < 1 ) {
				[self clearQuestionArray];
				[self getQuestion];			
			}
			else
				[self addAnswersToScrollView];		
		}
	
}

-(void)addAnswersToScrollView {
	// Add answers to scroll view
	NSLog(@"Quetion array count %d",[APP_DELEGATE.arrQuestions count]);	
	currentQuestion = [APP_DELEGATE.arrQuestions objectAtIndex:APP_DELEGATE.nCurrentQuestionIndex]; 
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString* strQuestionDelay = [defaults valueForKey:@"QUESTION_DELAY"];
 
	if([strQuestionDelay length] > 0) {
		btnSumbit.enabled = NO;
		btnSkip.enabled = NO;
		[self performSelector:@selector(enableSkipAndSubmit) withObject:nil afterDelay:[strQuestionDelay integerValue]];
	}

	btnBrand.hidden = NO;
	imgViewBrandBack.hidden = NO;
	lblBrand.hidden = NO;
	lblQuestion.hidden = NO;
	lblBrand.text = currentQuestion.strBrandDescription;		
	lblQuestion.text = currentQuestion.strQuestionTex;
	
	nNoOfAnswers = [currentQuestion.arrAnswer count];
	if(nNoOfAnswers <= 4)
		scrAnswers.contentSize = CGSizeMake(266, 247);
	else
		scrAnswers.contentSize = CGSizeMake(266, 380);
	
	for(UIView *subview in [scrAnswers subviews]) {
		[subview removeFromSuperview];
	}
	
	int nNoOfTextAnswer = 0;
	for(int i=0; i<nNoOfAnswers; i++) {
		CGRect frame;
		if(i==0)
			frame = CGRectMake(0, 0, 128, 118);
		else if(i == 1)
			frame = CGRectMake(138, 0, 128, 118);
		else if(i == 2)
			frame = CGRectMake(0, 122, 128, 118);
		else if(i == 3)
			frame = CGRectMake(138, 122, 128, 118);
		else if(i == 4)
			frame = CGRectMake(0, 244, 128, 118);
		else if(i == 5)
			frame = CGRectMake(138, 244, 128, 118);
		
		// Add answer background
		UIImageView* imgButtonBack = [[UIImageView alloc] init];			
		imgButtonBack.frame = frame;
		imgButtonBack.tag = i+3001;
		imgButtonBack.image = [UIImage imageNamed:@"bg_answer.png"];
		[scrAnswers addSubview:imgButtonBack];		
		
		// Add button for both text and image based answer
		UIButton* btnAnswer = [UIButton buttonWithType:UIButtonTypeCustom];
		btnAnswer.tag = i+1001;
		[btnAnswer addTarget:self action:@selector(OnButtonAnswer:) forControlEvents:UIControlEventTouchUpInside];
		CGRect temp = frame;
		temp.origin.x = temp.origin.x + 3;
		temp.origin.y = temp.origin.y + 3;
		temp.size.width = temp.size.width - 9;
		temp.size.height = temp.size.height - 9;			
		btnAnswer.frame = temp;
		[scrAnswers addSubview:btnAnswer];	
		
		// Add label for text based answer only
		NSString* strAnswerType = [currentQuestion.arrAnswerType objectAtIndex:i];
		if([strAnswerType isEqualToString:@"text"]) {
			nNoOfTextAnswer++;
			CGRect temp = frame;
			temp.origin.x = temp.origin.x + 10;
			temp.origin.y = temp.origin.y + 10;
			temp.size.width = temp.size.width - 20;
			temp.size.height = temp.size.height - 20;					
			UILabel* lblText = [[UILabel alloc] initWithFrame:temp];
			lblText.textAlignment = UITextAlignmentCenter;				
			lblText.text = [currentQuestion.arrAnswer objectAtIndex:i];
			lblText.numberOfLines = 5;
			lblText.font = [UIFont systemFontOfSize:12];
			[scrAnswers addSubview:lblText];				
		}			
	}
	
	// Set down arrow if questions more than 4
	bUserScrolledAllAnswers = NO;
	
	if([currentQuestion.strBrandLogoURL length] < 1) {
		btnBrand.hidden = YES;
		imgViewBrandBack.hidden = YES;
		lblQuestion.frame = CGRectMake(30, 15, 250, 70);
	}
	else {
		NSURL* strURL = [NSURL URLWithString:currentQuestion.strBrandLogoURL];
		NSData *imgData = [NSData dataWithContentsOfURL:strURL];
		if(imgData != nil){
			lblQuestion.frame = CGRectMake(117, 27, 176, 57);
			[btnBrand setImage: [UIImage imageWithData:imgData] forState:UIControlStateNormal];		
		}
	}
	
	for(int i=0; i<[currentQuestion.arrAnswer count]; i++){
		UIButton* btnTemp = (UIButton*)[scrAnswers viewWithTag:1001+i];
		NSString* strAnswerType = [currentQuestion.arrAnswerType objectAtIndex:i];
		if([strAnswerType isEqualToString:@"image"]) {
			NSString* strURL = [currentQuestion.arrAnswerImage objectAtIndex:i];
			if((![strURL isEqualToString:@"NO_IMAGE"]) && [strURL length] > 0) {
				NSURL* strURL = [NSURL URLWithString:[currentQuestion.arrAnswerImage objectAtIndex:i]];
				NSData *imgData = [NSData dataWithContentsOfURL:strURL];
				
				//compress the iamge
				UIImage* imageTemp = [UIImage imageWithData:imgData];
				CGSize tempsize = CGSizeMake(200, 200);
				UIImage* imageCompressed = [QuestionsViewController resizeImage:imageTemp resizeSize:tempsize];
				NSData *dataObj = UIImageJPEGRepresentation(imageCompressed, 1.0);
				[btnTemp setImage: [UIImage imageWithData:dataObj] forState:UIControlStateNormal];		
			}			
			//NSData* dataTemp = [currentQuestion.arrAnswerImage objectAtIndex:i];
			//[btnTemp setImage: [UIImage imageWithData:dataTemp] forState:UIControlStateNormal];		
		}
	}
	
	//Set brand iamge  //Old logic
	/*NSData* dataTemp = currentQuestion.dataBrandImage;
	if(dataTemp == nil) {
		btnBrand.hidden = YES;
		imgViewBrandBack.hidden = YES;
		lblQuestion.frame = CGRectMake(30, 15, 250, 70);
	}
	else {
		lblQuestion.frame = CGRectMake(117, 27, 176, 57);
		[btnBrand setImage: [UIImage imageWithData:dataTemp] forState:UIControlStateNormal];		
	}

	
	// Set Answer images if any of answer has
	for(int i=0; i<[currentQuestion.arrAnswer count]; i++){
		UIButton* btnTemp = (UIButton*)[scrAnswers viewWithTag:1001+i];
		NSString* strAnswerType = [currentQuestion.arrAnswerType objectAtIndex:i];
		if([strAnswerType isEqualToString:@"image"]) {
			NSData* dataTemp = [currentQuestion.arrAnswerImage objectAtIndex:i];
			[btnTemp setImage: [UIImage imageWithData:dataTemp] forState:UIControlStateNormal];		
		}
	}*/
	
	[[ActivityIndicator sharedActivityIndicator] hide];
}

-(void)enableSkipAndSubmit {
	btnSumbit.enabled = YES;
	btnSkip.enabled = YES;
}

-(void)clearQuestionArray {
	APP_DELEGATE.nCurrentQuestionIndex = 0;
	NSString* strKey = @"";
	strKey = [strKey stringByAppendingFormat:@"nCurrentQuestionIndex_%d",APP_DELEGATE.nUserID];
	[[NSUserDefaults standardUserDefaults] setInteger:APP_DELEGATE.nCurrentQuestionIndex forKey:strKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if(APP_DELEGATE.arrQuestions)
		[APP_DELEGATE.arrQuestions removeAllObjects];
	else {
		APP_DELEGATE.arrQuestions = [[NSMutableArray alloc] init];
	}
	[self saveQuestionArrayLocally];		
}

-(void)clearQuestionScreen {
	btnBrand.hidden = YES;
	imgViewBrandBack.hidden = YES;
	nSelectedAnswer = -1;
	lblBrand.hidden = YES;
	lblQuestion.hidden = YES;
	currentQuestion = nil;
	for(UIView *subview in [scrAnswers subviews]) {
		[subview removeFromSuperview];
	}		
}

- (void) loadImageInBackground:(NSArray *)urlAndTagReference  {
	// Create a pool
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	// Retrieve the remote image. Retrieve the imgURL from the passed in array
	NSData *imgData = [NSData dataWithContentsOfURL:[urlAndTagReference objectAtIndex:0]];
	UIImage *img    = [[UIImage alloc] initWithData:imgData];
	// Create an array with the URL and imageView tag to 
	// reference the correct imageView in background thread.
	if(imgData && img) {
		NSMutableArray *arr = [[NSArray alloc] initWithObjects:img, [urlAndTagReference objectAtIndex:1], nil  ];
		// Image retrieved, call main thread method to update image, passing it the downloaded UIImage
		[self performSelectorOnMainThread:@selector(assignImageToImageView:) withObject:arr waitUntilDone:YES];
		[pool release];	
	}else 
		[[ActivityIndicator sharedActivityIndicator] hide];	
	
}

- (void) assignImageToImageView:(NSArray *)imgAndTagReference {
	// Create a pool
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	int nTag = [[imgAndTagReference objectAtIndex:1] integerValue];
	if(nTag == 1000) {
		UIButton* btnTemp = (UIButton*)[self.view viewWithTag:1000];
		[btnTemp setImage: [imgAndTagReference objectAtIndex:0]forState:UIControlStateNormal];		
	}
	else {
		int nTag = [[imgAndTagReference objectAtIndex:1] integerValue];
		NSLog(@"tag2 %d",nTag);
		UIButton* btnTemp = (UIButton*)[scrAnswers viewWithTag:nTag];
		[btnTemp setImage: [imgAndTagReference objectAtIndex:0]forState:UIControlStateNormal];		
	}
	// loop
	// release the pool
	[pool release];
	
	[[ActivityIndicator sharedActivityIndicator] hide];	
}

-(void)saveQuestionArrayLocally {
	// Get new question if new user login via signup or buffer is empty
	NSLog(@"===========================");
	NSLog(@"Current Question Index %d",APP_DELEGATE.nCurrentQuestionIndex);
	NSLog(@"Question Array Count %d",[APP_DELEGATE.arrQuestions count]);
	NSLog(@"===========================");	
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) ;
	NSString * documentsDirectory = [paths objectAtIndex:0];
	NSString* pathComponent = @"";
	pathComponent =[NSString stringWithFormat:@"questionArray_%d",APP_DELEGATE.nUserID];
	documentsDirectory = [documentsDirectory stringByAppendingPathComponent:pathComponent];
	BOOL bStatus =  [NSKeyedArchiver archiveRootObject:APP_DELEGATE.arrQuestions toFile:documentsDirectory];
	if(bStatus) {
		[[NSUserDefaults standardUserDefaults] synchronize];
		//NSLog(@"Question array saved successfully");
	}
	else
		NSLog(@"Problem saving question array");
}

-(void)saveUnpostedAnswerArrayLocally {
	NSLog(@"===========================");
	NSLog(@"Unposted array count %d",[APP_DELEGATE.arrUnpostedAnswers count]);
	NSLog(@"===========================");	
	// Save updated unposted answer array locally
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) ;
	NSString * documentsDirectory = [paths objectAtIndex:0];
	NSString* pathComponent = @"";
	pathComponent =[NSString stringWithFormat:@"unpostedAnswersArray_%d",APP_DELEGATE.nUserID];
	documentsDirectory = [documentsDirectory stringByAppendingPathComponent:pathComponent];
	BOOL bStatus =  [NSKeyedArchiver archiveRootObject:APP_DELEGATE.arrUnpostedAnswers toFile:documentsDirectory];
	if(bStatus) {
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	else
		NSLog(@"Problem saving question array");
}

-(void)moveToHomeScreen {
	BOOL bHomeViewFound = NO;
	for(UIViewController* vc in APP_DELEGATE.navController.viewControllers) {	
		if([vc.nibName isEqualToString:@"HomeViewController"]) {
			bHomeViewFound = YES;
			HomeViewController* homeVC = (HomeViewController*)vc;
			[APP_DELEGATE.navController popToViewController:homeVC animated:NO];
			
		}		
	}	
	if(!bHomeViewFound) { // In case credentials saved so moved directly to question screen
		HomeViewController* _HomeViewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
		APP_DELEGATE.navController = [[UINavigationController alloc] initWithRootViewController:_HomeViewController];
		APP_DELEGATE.navController.navigationBar.hidden = YES;
		[APP_DELEGATE.window addSubview:APP_DELEGATE.navController.view];
	}			
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
	[[ActivityIndicator sharedActivityIndicator] hide];		
	viewIntro.hidden = YES;
	[connection release];
	theConnection = nil;
    [receivedData release];	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {	
	if(nCurrentWebserviceCall == WEB_SERVICE_CALL_POST_UNPOSTED_ANSWER) { // hanlde post of answer answered questions
		NSString* strResponse = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
		strResponse = [strResponse stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[receivedData release];
		[[ActivityIndicator sharedActivityIndicator] hide];		   
		[APP_DELEGATE.arrUnpostedAnswers removeObjectAtIndex:0];
		[self saveUnpostedAnswerArrayLocally];
		[self showNextQuestion];
	}
	else if(nCurrentWebserviceCall == WEB_SERVICE_CALL_POST_DEVICE_ID) {	// Handle post device ID webserivce response
		NSString* strResponse = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
		strResponse = [strResponse stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[receivedData release];
		
		if([strResponse isEqualToString:@"{\"appinion\":false}"]) {
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Failed posting device UDID" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			return;
		}
		else {
			bShowIntroScreen = YES;
			[self moveToNextQuestion];
			bShowIntroScreen = NO;
		}
	 }
	else if(nCurrentWebserviceCall == WEB_SERVICE_CALL_GET_QUESTION) {
		
		viewIntro.hidden = YES;

		NSString* strResponse = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
		strResponse = [strResponse stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[receivedData release];
		
		SBJSON *json = [[SBJSON alloc] init];
		NSError *error = nil;
		NSDictionary *results = [json objectWithString:strResponse error:&error];		
		NSArray* arrItems = [results objectForKey:@"appinion"];
		NSDictionary* dicCount = [arrItems objectAtIndex:[arrItems count]-1];
		int nQuestionCount = [[dicCount valueForKey:@"question_count"] integerValue];
		
		NSDictionary* dicDelay = [arrItems objectAtIndex:[arrItems count]-2];
		APP_DELEGATE.nQuestionDelay  = [[dicDelay valueForKey:@"question_time"] integerValue];
		NSString* strQuestionDelay = [NSString stringWithFormat:@"%d",APP_DELEGATE.nQuestionDelay];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:strQuestionDelay forKey:@"QUESTION_DELAY"];
		[[NSUserDefaults standardUserDefaults] synchronize];

		// Collect all question from JSON response to array		
		NSDictionary* dictQuestion;
		NSDictionary* dictQuestionInfo;
		NSDictionary* dictQuestionInfoDetail;
		NSDictionary* dictAnswerCount;
		NSDictionary* dictAnswer;
		NSDictionary* dictAnswerDetail;
		NSString* strTemp1;
		NSArray* arrQuestionDetail;
		
		if(nQuestionCount < 1) {
			[[ActivityIndicator sharedActivityIndicator] hide];

			NSDictionary* dictMessage = [arrItems objectAtIndex:0];
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:[dictMessage valueForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			alert.tag = 5000;
			[alert show];
			[alert release];			
			[self clearQuestionScreen];			
			return;
			
		}
		
		for(int i=0; i<nQuestionCount; i++){
			dictQuestion = [arrItems objectAtIndex:i];			
			strTemp1 = [NSString stringWithFormat:@"question%d",i];			
			arrQuestionDetail = [dictQuestion valueForKey:strTemp1];
			dictQuestionInfo = [arrQuestionDetail objectAtIndex:0];
			dictQuestionInfoDetail = [dictQuestionInfo valueForKey:@"question_info"];
		
			dictAnswerCount = [arrQuestionDetail objectAtIndex:[arrQuestionDetail count]-1]; 
			int nAnswerCount = [[dictAnswerCount objectForKey:@"answer_count"] integerValue];

			Question* temp = [[Question alloc] init];
			temp.strQuestionID  = [dictQuestionInfoDetail	valueForKey:@"question_id"];
			temp.strBrandDescription = [dictQuestionInfoDetail valueForKey:@"brand"];
			temp.strBrandLogoLink = [dictQuestionInfoDetail valueForKey:@"brand_logo_link"];
			temp.strBrandLogoURL = [dictQuestionInfoDetail valueForKey:@"brand_logo_url"];
			temp.strQuestionTex = [dictQuestionInfoDetail valueForKey:@"question_text"];
			temp.nBrandLogoStatus = [[dictQuestionInfoDetail valueForKey:@"brand_like_status"] integerValue];
			temp.arrAnswer = [[NSMutableArray alloc] init];
			temp.arrAnswerType = [[NSMutableArray alloc] init];
			temp.arrAnswerImage = [[NSMutableArray alloc] init];

			for(int i=0; i<nAnswerCount;i++){
				[temp.arrAnswerImage addObject:@"NO_IMAGE"];
			}
			NSURL* imgURL;
			NSString* strURL = BASE_URL_BRAND_IMAGE;
			NSString* strImageName = [dictQuestionInfoDetail valueForKey:@"brand_logo_url"];
			if([strImageName length] > 0) {
				strURL = [strURL stringByAppendingString:strImageName];
				imgURL = [NSURL URLWithString:strURL];
				temp.strBrandLogoURL = strURL;
				/*NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
				if(imgData)
					temp.dataBrandImage = imgData;*/
			}
			else {
				temp.strBrandLogoURL = @"";
			}

			/*else
				temp.dataBrandImage = nil;*/
			
			// Save answer type , Answer text or Answer image 
			for(int i=0; i<nAnswerCount; i++) {
				dictAnswer = [arrQuestionDetail objectAtIndex:i+1];
				NSString* strAnswer = [NSString stringWithFormat:@"answer%d",i+1];
				dictAnswerDetail = [dictAnswer objectForKey:strAnswer];
				[temp.arrAnswer addObject:[dictAnswerDetail objectForKey:@"text"]];
				[temp.arrAnswerType addObject:[dictAnswerDetail objectForKey:@"answer_type"]];
				
				NSString* strAnswerType = [dictAnswerDetail objectForKey:@"answer_type"];
				if([strAnswerType isEqualToString:@"image"]) {
					NSString* strURL = BASE_URL_ANSWER_IMAGE;
					NSString* strImageName = [dictAnswerDetail objectForKey:@"text"];
					if([strImageName length] > 0) {
						strURL = [strURL stringByAppendingString:strImageName];
						[temp.arrAnswerImage replaceObjectAtIndex:i withObject:strURL];
					}
					/*imgURL = [NSURL URLWithString:strURL];
					NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
					UIImage* imageTemp = [UIImage imageWithData:imgData];
					CGSize tempsize = CGSizeMake(200, 200);
					UIImage* imageCompressed = [QuestionsViewController resizeImage:imageTemp resizeSize:tempsize];
					NSData *dataObj = UIImageJPEGRepresentation(imageCompressed, 1.0);
					if(dataObj)
						[temp.arrAnswerImage replaceObjectAtIndex:i withObject:dataObj];*/
				}
			}
			
			[APP_DELEGATE.arrQuestions addObject:temp];
			[temp release];		

		}	
			
		[self saveQuestionArrayLocally];
		[self addAnswersToScrollView];		
	}	
	else if(nCurrentWebserviceCall == WEB_SERVICE_CALL_POST_ANSWER){
		NSString* strResponse = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
		strResponse = [strResponse stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[receivedData release];
		[[ActivityIndicator sharedActivityIndicator] hide];		   
		SBJSON *json = [[SBJSON alloc] init];
		NSError *error = nil;
		NSDictionary *results = [json objectWithString:strResponse error:&error];		
		NSArray* arrItems = [results objectForKey:@"appinion"];
		NSDictionary* dictMessage = [arrItems objectAtIndex:0];
		NSString* strMessage = [dictMessage objectForKey:@"message"];
		if([strMessage isEqualToString:@"success"]) {
			nCurrentQuestionNumber++; // move to next question
			APP_DELEGATE.nCurrentQuestionIndex++;
			NSString* strKey = @"";
			strKey = [strKey stringByAppendingFormat:@"nCurrentQuestionIndex_%d",APP_DELEGATE.nUserID];
			[[NSUserDefaults standardUserDefaults] setInteger:APP_DELEGATE.nCurrentQuestionIndex forKey:strKey];
			[[NSUserDefaults standardUserDefaults] synchronize];
			[self moveToNextQuestion];
		}
		else {
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:strMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
	else if(nCurrentWebserviceCall == WEB_SERVICE_CALL_GET_BRAND_LIKE_STATUS) {	// Handle brand like status get
		NSString* strResponse = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
		strResponse = [strResponse stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[receivedData release];
		
		SBJSON *json = [[SBJSON alloc] init];
		NSError *error = nil;
		NSDictionary *results = [json objectWithString:strResponse error:&error];		
		NSArray* arrItems = [results objectForKey:@"appinion"];
		NSDictionary* dictMessage = [arrItems objectAtIndex:0];
		int nStatus = [[dictMessage objectForKey:@"status"] integerValue];		
		if(nStatus == 1) {
		}
		else {
			UIFont* font = [UIFont systemFontOfSize:12];
			CGSize size = [currentQuestion.strBrandDescription sizeWithFont:font];
			CGRect frameLable = lblBrand.frame;

			if(size.width < 240)
				frameLable.size.width = size.width + 5;
			else
				frameLable.size.width = 240;				
				
			lblBrand.frame = frameLable;
		}
	}
		
}	

#pragma mark Button actions

-(IBAction)OnButtonAnswer:(id)sender {
	UIButton* btnSelected = (UIButton*)sender;
	nSelectedAnswer = btnSelected.tag - 1001;
	UIImageView* imgView = (UIImageView*)[scrAnswers viewWithTag:3001+nSelectedAnswer];
	for(int i=0; i<nNoOfAnswers; i++) {
		if(i == nSelectedAnswer)
			imgView.image = [UIImage imageNamed:@"bg_answer_hower.png"];
		else {
			UIImageView* imgView = (UIImageView*)[scrAnswers viewWithTag:i+3001];
			imgView.image = [UIImage imageNamed:@"bg_answer.png"];
		}
	}
}

-(IBAction)OnButtonHome:(id)sender {
	
	//self.view.hidden = TRUE;
	NSLog(@"===========================");
	NSLog(@"Unposted array count %d",[APP_DELEGATE.arrUnpostedAnswers count]);
	NSLog(@"===========================");	
	animationView.alpha = 0;
	animationView.transform = CGAffineTransformMakeScale(1.0,1.0);
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.4];
	animationView.transform = CGAffineTransformMakeScale(0.1,0.1);
	animationView.alpha = 1;	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView commitAnimations];
}

- (void)animationDidStop:(NSString*)animationID finished:(BOOL)finished context:(void *)context {
	[self moveToHomeScreen]; //Test

}
-(IBAction)OnButtonSubmit:(id)sender { 
	
	UIButton* btn = (UIButton*)sender;
	NSLog(@"button tag %d",btn.tag);
	
	if(APP_DELEGATE.netStatus == NotReachable) { //Test
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Internet connection is not available. Please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}

	if([APP_DELEGATE.arrQuestions count] < 1 || (!currentQuestion)) {
		[self getQuestion];
	}

	if([currentQuestion.arrAnswer count] > 4 && (!bUserScrolledAllAnswers)) { // User should have scroll through all the answers .. in case of more than 4 answers
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Please scroll through all answers" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	if(nSelectedAnswer < 0 && btn.tag == 2001 && [APP_DELEGATE.arrQuestions count] > 0) { // Give alert to select answer on submit. Not for skip
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Please select any one answer" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	[[ActivityIndicator sharedActivityIndicator] show];
	nCurrentWebserviceCall = WEB_SERVICE_CALL_POST_ANSWER;
	NSString* strURL = @"";
	strURL = [strURL stringByAppendingString:BASE_URL];
	strURL = [strURL stringByAppendingString:@"?action=save"];
	NSString * encodedURL = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)strURL,NULL,(CFStringRef)@" ",kCFStringEncodingUTF8 );
	
	NSString* strBody = @"";
	strBody = [strBody stringByAppendingFormat:@"question_id=%@",currentQuestion.strQuestionID];
	if(btn.tag == 2000) // skip
		strBody = [strBody stringByAppendingFormat:@"&answer="];
	else				// submit
		strBody =  [strBody stringByAppendingFormat:@"&answer=%@",[currentQuestion.arrAnswer objectAtIndex:nSelectedAnswer]];
	strBody = [strBody stringByAppendingFormat:@"&user_id=%d",APP_DELEGATE.nUserID];
	//NSString * encodedBody = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)strBody,NULL,(CFStringRef)@" ",kCFStringEncodingUTF8 );
	strBody = [strBody stringByReplacingOccurrencesOfString:@"'" withString:@"''"];	
	NSData* postData = [strBody dataUsingEncoding:NSUTF8StringEncoding];
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

-(IBAction)OnButtonInfo:(id)sender {
	InfoViewController* _InfoViewController = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
	[APP_DELEGATE.navController pushViewController:_InfoViewController animated:YES];
	[_InfoViewController release];
}

-(IBAction)OnButtonBrand:(id)sender {	
	NSArray *arr = [currentQuestion.strBrandLogoLink componentsSeparatedByString:@"http://"];
	if([arr count] == 2) // http found
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:currentQuestion.strBrandLogoLink]];
	else {
		NSString* strTemp = @"http://";
		strTemp = [strTemp stringByAppendingString:currentQuestion.strBrandLogoLink];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:strTemp]];
	}
}

#pragma mark scroll view delegate 
- (void)scrollViewDidScroll:(UIScrollView *)sender {
	if([currentQuestion.arrAnswer count] > 4) {
		if (lastContentOffset > scrAnswers.contentOffset.y)
			nScrollViewDirection = SCROLL_VIEW_DIRECTION_UP;
		else if (lastContentOffset < scrAnswers.contentOffset.y) {
			bUserScrolledAllAnswers = YES;
			nScrollViewDirection = SCROLL_VIEW_DIRECTION_DOWN;
		}
		lastContentOffset = scrAnswers.contentOffset.x;
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
	if(theConnection) {
		[theConnection release];
		theConnection = nil;
	}	
    [super dealloc];
}


@end
