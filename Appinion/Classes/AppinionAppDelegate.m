//
//  AppinionAppDelegate.m
//  Appinion
//
//  Created by Sunil Adhyaru on 02/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppinionAppDelegate.h"

@implementation AppinionAppDelegate

@synthesize window;
@synthesize navController;
@synthesize netStatus; 
@synthesize nCreditPointIncreseCount;
@synthesize nUserID;
@synthesize arrCity;
@synthesize arrCountry;
@synthesize arrState;
@synthesize arrQuestions;
@synthesize nCurrentQuestionIndex;
@synthesize arrUnpostedAnswers;
@synthesize _deviceToken;
@synthesize payload;
@synthesize certificate;
@synthesize bIsUserLoggedIn;
@synthesize strSelectedCountry;
@synthesize strSelectedCountryID;
@synthesize strSelectedState;
@synthesize strSelectedStateID;
@synthesize strSelectedCity;
@synthesize strSelectedCityID;
@synthesize strQuestionCount;
@synthesize strCreditCount;
@synthesize bLoginFromSavedCredentials;
@synthesize nQuestionDelay;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	
	// Reachability.
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    Reachability* internetReach = [[Reachability reachabilityForInternetConnection] retain];
	//Reachability* internetReach = [[Reachability reachabilityWithHostName:HOST_NAME] retain];
	[internetReach startNotifier];
	self.netStatus = [internetReach currentReachabilityStatus];	
	
	APP_DELEGATE.nUserID = -1;
	bIsUserLoggedIn = NO;

    // Override point for customization after application launch.
	NSString* strUserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"];
	NSString* strPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPassword"];
	
		// Add the navigation controller's view to the window and display.
	if([strUserName length] > 0 && [strPassword length] > 0 && (!(APP_DELEGATE.netStatus == NotReachable))){
		
		NSString* strUDID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UDID"];

		[[ActivityIndicator sharedActivityIndicator] show];
		QuestionsViewController* _QuestionsViewController = [[QuestionsViewController alloc] initWithNibName:@"QuestionsViewController" bundle:nil];
		navController = [[UINavigationController alloc] initWithRootViewController:_QuestionsViewController];
		navController.navigationBar.hidden = YES;
		[self.window addSubview:navController.view];
		[self.window makeKeyAndVisible];
		
		bIsWebserviceForLogin = TRUE;
		
		bLoginFromSavedCredentials = YES;
		nCurrentWebserviceCall = WEB_SERVICE_CALL_LOGIN;

		NSString* strURL = @"";
		strURL = [strURL stringByAppendingString:BASE_URL];
		strURL = [strURL stringByAppendingString:@"?action=login"];
		strURL = [strURL stringByAppendingFormat:@"&username=%@",strUserName];
		strURL = [strURL stringByAppendingFormat:@"&password=%@",strPassword];
		if([strUDID length] > 0)
			strURL = [strURL stringByAppendingFormat:@"&deviceid=%@",strUDID];
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
	else {
		
		if(APP_DELEGATE.netStatus == NotReachable) {
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Internet connection is not available. Please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
		
		bLoginFromSavedCredentials = NO; 
		LoginViewController* _LoginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
		navController = [[UINavigationController alloc] initWithRootViewController:_LoginViewController];
		navController.navigationBar.hidden = YES;
		[self.window addSubview:navController.view];
	}

    [self.window makeKeyAndVisible];
	
	NSLog(@"Registering for push notifications...");    
	[[UIApplication sharedApplication] 
	 registerForRemoteNotificationTypes:
	 (UIRemoteNotificationTypeAlert |
	  UIRemoteNotificationTypeBadge
	  )];
	
    return YES;
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
	if(nCurrentWebserviceCall == WEB_SERVICE_CALL_LOGIN) { // Handle login response
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
			
			nCurrentWebserviceCall = WEB_SERVICE_CALL_GET_INCREMENT_VALUE_OF_CREDIT_COUNT;
			
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
			[[ActivityIndicator sharedActivityIndicator] hide];
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:strMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			return;
		}
	}
	else if(nCurrentWebserviceCall == WEB_SERVICE_CALL_GET_INCREMENT_VALUE_OF_CREDIT_COUNT){								// handle credit point increment value 
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
		
		nCurrentWebserviceCall = WEB_SERVICE_CALL_GET_TOTAL_CREDIT_COUNTS;
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
	else if(nCurrentWebserviceCall == WEB_SERVICE_CALL_GET_TOTAL_CREDIT_COUNTS){
		NSString* strResponse = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
		[receivedData release];
		SBJSON *json = [[SBJSON alloc] init];
		NSError *error = nil;
		NSDictionary *results = [json objectWithString:strResponse error:&error];		
		NSArray* arrItems = [results objectForKey:@"appinion"];
		NSDictionary* firstItem = [arrItems objectAtIndex:0];
		//lblCreditCount.text  = [firstItem objectForKey:@"credit_points"];
		[APP_DELEGATE saveCreditCountLocally:[firstItem objectForKey:@"credit_points"]];
		nCurrentWebserviceCall = WEB_SERVICE_CALL_GET_TOTAL_QUESTION_COUNT;
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
	else if(nCurrentWebserviceCall == WEB_SERVICE_CALL_GET_TOTAL_QUESTION_COUNT) {
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
		
		QuestionsViewController* QVC =  [APP_DELEGATE.navController.viewControllers  objectAtIndex:0];
		[QVC showNextQuestion];
		[[ActivityIndicator sharedActivityIndicator] hide];
	}
	
	/*if(bIsWebserviceForLogin == TRUE) { // Handle login response
		NSString* strResponse = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
		[receivedData release];
		bIsWebserviceForLogin = FALSE;
		
		SBJSON* json = [[SBJSON alloc] init];
		NSError* error = nil;
		NSDictionary *results = [json objectWithString:strResponse error:&error];		
		NSArray* arrItems = [results objectForKey:@"appinion"];
		NSDictionary *firstItem = [arrItems objectAtIndex:0];
		NSString* strMessage = [firstItem valueForKey:@"message"];
		if([strMessage isEqualToString:@"Login Successful"]) { // valid credentials , Now get credit points 		
			APP_DELEGATE.bIsUserLoggedIn = YES;
			NSString* strUserID = [firstItem valueForKey:@"user_id"];
			APP_DELEGATE.nUserID = [strUserID integerValue];
			NSString* strURL = @"";
			strURL = [strURL stringByAppendingString:BASE_URL];
			strURL = [strURL stringByAppendingString:@"?action=credit_data"]; /// for increse count
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
			[[ActivityIndicator sharedActivityIndicator] hide];
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:strMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			return;
		}
	}
	else {								// handle credit poing response 
		NSString* strResponse = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
		SBJSON *json = [[SBJSON alloc] init];
		NSError *error = nil;
		NSDictionary *results = [json objectWithString:strResponse error:&error];		
		NSArray* arrItems = [results objectForKey:@"appinion"];
		NSDictionary* firstItem = [arrItems objectAtIndex:0];
		NSString* strCreditPoint = [firstItem objectForKey:@"total_credit"];
		APP_DELEGATE.nCreditPointIncreseCount = [strCreditPoint integerValue];	
		[APP_DELEGATE getLocallySavedItems];
		[receivedData release];
		[[ActivityIndicator sharedActivityIndicator] hide];
		
		QuestionsViewController* _QuestionsViewController = [[QuestionsViewController alloc] initWithNibName:@"QuestionsViewController" bundle:nil];
		navController = [[UINavigationController alloc] initWithRootViewController:_QuestionsViewController];
		navController.navigationBar.hidden = YES;
		[self.window addSubview:navController.view];
	}*/
	
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken { 
    //NSString *str = [NSString stringWithFormat:@"Device Token=%@",deviceToken];
	//NSLog(str);
	self._deviceToken =  [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]copy];
	
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err { 
   // NSString *str = [NSString stringWithFormat: @"Error: %@", err];
   // NSLog(str);    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    for (id key in userInfo) {
        NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
		NSDictionary* temp = [userInfo objectForKey:key];
		dictPushnotification  = temp;

		int nQuestionCount = [[temp valueForKey:@"badge"] integerValue];
		NSString* strAlert = [temp valueForKey:@"alert"];
 
		if([strAlert length] > 0) {
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:strAlert delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			alert.tag = 5000;
			[alert show];
			[alert release];
		}
		
		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:nQuestionCount];

		[APP_DELEGATE saveQuestionCountLocally:[NSString stringWithFormat:@"%d",nQuestionCount]];
		
		BOOL bHomeFound = NO;
		HomeViewController* homeVC;
		for(UIViewController* vc in APP_DELEGATE.navController.viewControllers) {	
			if([vc.nibName isEqualToString:@"HomeViewController"]) {
				bHomeFound = YES;
				homeVC = (HomeViewController*)vc;
				break;
			}		
		}	
		if (bHomeFound) {
			int nTotal = [APP_DELEGATE.navController.viewControllers count];
			UIViewController* vc = [APP_DELEGATE.navController.viewControllers objectAtIndex:nTotal-1];
			if([vc.nibName isEqualToString:@"HomeViewController"]) 
				homeVC.lblQuestionCount.text = [APP_DELEGATE getLocallySavedQuestionCount];
		}
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(alertView.tag == 5000) {
		if(APP_DELEGATE.nUserID > 0) {			
			if(APP_DELEGATE.netStatus == NotReachable) {
				
			}			
			else {
				BOOL bQuestionViewFound = NO;
				QuestionsViewController* queVC;
				for(UIViewController* vc in APP_DELEGATE.navController.viewControllers) {	
					if([vc.nibName isEqualToString:@"QuestionsViewController"]) {
						bQuestionViewFound = YES;
						queVC = (QuestionsViewController*)vc;
						break;
					}		
				}	
				if ( bQuestionViewFound ) {
					int nTotal = [APP_DELEGATE.navController.viewControllers count];
					UIViewController* vc = [APP_DELEGATE.navController.viewControllers objectAtIndex:nTotal-1];
					if([vc.nibName isEqualToString:@"QuestionsViewController"]) 
						[queVC showNextQuestion];
				}
			}

		}			
	
	}
}

-(void)getLocallySavedItems {
	// Get locally saved current question index
	NSString* strKeyIndex = @"";
	strKeyIndex = [strKeyIndex stringByAppendingFormat:@"nCurrentQuestionIndex_%d",APP_DELEGATE.nUserID];
	APP_DELEGATE.nCurrentQuestionIndex = [[NSUserDefaults standardUserDefaults] integerForKey:strKeyIndex];
	
	// Get locally stored questions
	NSString* strKeyQestions = @"";
	strKeyQestions = [strKeyQestions stringByAppendingFormat:@"questionArray_%d",APP_DELEGATE.nUserID];
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) ;
	NSString * documentsDirectory = [paths objectAtIndex:0];
	documentsDirectory = [documentsDirectory stringByAppendingPathComponent:strKeyQestions];
	NSFileManager *fileMgr = [NSFileManager defaultManager];
	if ([fileMgr fileExistsAtPath:documentsDirectory]) {
		APP_DELEGATE.arrQuestions = [NSKeyedUnarchiver unarchiveObjectWithFile:documentsDirectory];
	} else {
		APP_DELEGATE.arrQuestions = [[NSMutableArray alloc] init];
	}
	
	// Get locally stored unposted answers
	NSString* strKeyUnpostedAnswers = @"";
	strKeyUnpostedAnswers = [strKeyUnpostedAnswers stringByAppendingFormat:@"unpostedAnswersArray_%d",APP_DELEGATE.nUserID];
	paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) ;
	documentsDirectory = [paths objectAtIndex:0];
	documentsDirectory = [documentsDirectory stringByAppendingPathComponent:strKeyUnpostedAnswers];
	fileMgr = [NSFileManager defaultManager];
	if ([fileMgr fileExistsAtPath:documentsDirectory]) {
		APP_DELEGATE.arrUnpostedAnswers = [NSKeyedUnarchiver unarchiveObjectWithFile:documentsDirectory];
	} else {
		APP_DELEGATE.arrUnpostedAnswers = [[NSMutableArray alloc] init];
	}
	
	
	NSLog(@"===========================");
	NSLog(@"Unposted question array count %d",[APP_DELEGATE.arrUnpostedAnswers count]);
	NSLog(@"question array count %d",[APP_DELEGATE.arrQuestions count]);
	NSLog(@"current question index %d",APP_DELEGATE.nCurrentQuestionIndex);
	NSLog(@"===========================");
}

-(NSString*)getLocallySavedQuestionCount {
	NSString* strKey = @"";
	strKey = [strKey stringByAppendingFormat:@"QuestionCount_%d",APP_DELEGATE.nUserID];
	self.strQuestionCount = [[NSUserDefaults standardUserDefaults] valueForKey:strKey];
	return self.strQuestionCount;
}

-(void)saveQuestionCountLocally:(NSString*)QuestionCount {
	NSString* strKey = @"";
	strKey = [strKey stringByAppendingFormat:@"QuestionCount_%d",APP_DELEGATE.nUserID];
	[[NSUserDefaults standardUserDefaults] setObject:QuestionCount  forKey:strKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)getLocallySavedCreditCount {
	NSString* strKey = @"";
	strKey = [strKey stringByAppendingFormat:@"CreditCount_%d",APP_DELEGATE.nUserID];
	self.strCreditCount = [[NSUserDefaults standardUserDefaults] valueForKey:strKey];
	return self.strCreditCount;
}

-(void)saveCreditCountLocally:(NSString*)CreditCount {
	NSString* strKey = @"";
	strKey = [strKey stringByAppendingFormat:@"CreditCount_%d",APP_DELEGATE.nUserID];
	[[NSUserDefaults standardUserDefaults] setObject:CreditCount  forKey:strKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark Reachability

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note {
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	self.netStatus = [curReach currentReachabilityStatus];
	
	if(self.netStatus == NotReachable) {		
		[[ActivityIndicator sharedActivityIndicator] hide];
	}
	else {
		
	}			
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
	BOOL bQuestionScreenFound = NO;
	QuestionsViewController* queVC;
	for(UIViewController* vc in APP_DELEGATE.navController.viewControllers) {	
		if([vc.nibName isEqualToString:@"QuestionsViewController"]) {
			bQuestionScreenFound = YES;
			queVC = (QuestionsViewController*)vc;
			break;
		}		
	}	
	if (bQuestionScreenFound) {
		int nTotal = [APP_DELEGATE.navController.viewControllers count];
		UIViewController* vc = [APP_DELEGATE.navController.viewControllers objectAtIndex:nTotal-1];
		if([vc.nibName isEqualToString:@"QuestionsViewController"]) {
			NSLog(@"***************** bQuestionScreenFound ********************");
			//[queVC moveToNextQuestion];
		}
	}	
	else {
		BOOL bHomeViewFound = NO;
		HomeViewController* homeVC;
		for(UIViewController* vc in APP_DELEGATE.navController.viewControllers) {	
			if([vc.nibName isEqualToString:@"HomeViewController"]) {
				bHomeViewFound = YES;
				homeVC = (HomeViewController*)vc;
				break;
			}		
		}	
		if (bHomeViewFound) {
			int nTotal = [APP_DELEGATE.navController.viewControllers count];
			UIViewController* vc = [APP_DELEGATE.navController.viewControllers objectAtIndex:nTotal-1];
			if([vc.nibName isEqualToString:@"HomeViewController"]) {
				[homeVC viewWillAppear:YES];
			}
		}	
		
	}

    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[arrCity release];
	[arrCountry release];
	[arrState release];	
	[navController release];
	[strSelectedCountry release];
	[strSelectedCountryID release];
	[strSelectedState release];
	[strSelectedStateID release];
	[strSelectedCity release];
	[strSelectedCityID release];
	[strQuestionCount release];
	[strCreditCount release];

	[window release];
	[super dealloc];
}


@end

