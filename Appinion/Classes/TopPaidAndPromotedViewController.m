//
//  TopPaidAndPromotedViewController.m
//  Appinion
//
//  Created by ripalvyas on 03/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TopPaidAndPromotedViewController.h"


@implementation TopPaidAndPromotedViewController

@synthesize isTopPaidFlag,appinionArray,topPaidArray,promotedArray;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	//scrollView.frame = CGRectMake(20, 70, 280, 370);
	[[ActivityIndicator sharedActivityIndicator] show];

	bToppaidCallFromViewLoad = YES;
	isTopPaidFlag = TRUE;
	if(isTopPaidFlag) {		
		//[self performSelectorOnMainThread:@selector(loadTopPaidData) withObject:nil waitUntilDone:YES];
		[NSThread detachNewThreadSelector:@selector(loadTopPaidData) toTarget:self withObject:nil];
	}
}


-(void)viewWillAppear:(BOOL)animated{
	TransitionScale.alpha = 0;
	TransitionScale.transform = CGAffineTransformMakeScale(0.2,0.2);
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.4];
	TransitionScale.transform = CGAffineTransformMakeScale(1.0,1.0);
	TransitionScale.alpha = 1;	
	[UIView commitAnimations];
	
	if(isTopPaidFlag) {
		[btnTopPaid setImage:[UIImage imageNamed:@"toppaid.png"] forState:UIControlStateNormal];
		[btnPromoted setImage:[UIImage imageNamed:@"promoted_hover.png"] forState:UIControlStateNormal];
		//[btnTopPaidAndPromoted setImage:[UIImage imageNamed:@"promoted.png"] forState:UIControlStateNormal];
	}else {
		[btnTopPaid setImage:[UIImage imageNamed:@"toppaid_hover.png"] forState:UIControlStateNormal];
		[btnPromoted setImage:[UIImage imageNamed:@"promoted.png"] forState:UIControlStateNormal];
		//[btnTopPaidAndPromoted setImage:[UIImage imageNamed:@"toppaid.png"] forState:UIControlStateNormal];
	}
}

-(IBAction)OnButtonTopPaid:(id)sender {	
	if(isTopPaidFlag)
		return;
	isTopPaidFlag = TRUE;
	[btnTopPaid setImage:[UIImage imageNamed:@"toppaid.png"] forState:UIControlStateNormal];
	[btnPromoted setImage:[UIImage imageNamed:@"promoted_hover.png"] forState:UIControlStateNormal];
	if(APP_DELEGATE.netStatus == NotReachable) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Please connect to internet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		return;
	}	
	[[ActivityIndicator sharedActivityIndicator] show];
	[NSThread detachNewThreadSelector:@selector(loadTopPaidData) toTarget:self withObject:nil];
	
}

-(IBAction)OnButtonPromoted:(id)sender {
	if(isTopPaidFlag == FALSE)
		return;
	isTopPaidFlag = FALSE;
	[btnTopPaid setImage:[UIImage imageNamed:@"toppaid_hover.png"] forState:UIControlStateNormal];
	[btnPromoted setImage:[UIImage imageNamed:@"promoted.png"] forState:UIControlStateNormal];
	if(APP_DELEGATE.netStatus == NotReachable) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Please connect to internet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		return;
	}	
	[[ActivityIndicator sharedActivityIndicator] show];
		[NSThread detachNewThreadSelector:@selector(loadPromotedData) toTarget:self withObject:nil];
}

-(void)loadTopPaidData{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[self setTopPaidArray:[self getServiceData:@"paid"]];		
	if ([topPaidArray count]==0) {
		NSLog(@"Promoted array null");
		
	}else {
		NSLog(@"Promoted");
		[self displayDataInScrollView:topPaidArray];		
	}
	if(bToppaidCallFromViewLoad == NO) { // dont make flip animation first time
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:1.0];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
							   forView:TransitionScrollTopPaid
								 cache:YES];
		[UIView commitAnimations];
	}
	[btnTopPaidAndPromoted setImage:[UIImage imageNamed:@"promoted.png"] forState:UIControlStateNormal];
	bToppaidCallFromViewLoad = NO;
	[pool release];
	pool = nil;
}

-(void)loadPromotedData{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[self setPromotedArray:[self getServiceData:@"promoted"]];
	if ([promotedArray count]==0) {
		NSLog(@"Promoted array null");
		
	}else {
		NSLog(@"Promoted");
		[self displayDataInScrollView:promotedArray];		
	}
//	TransitionScrollTopPaid = [[UIView alloc] initWithFrame:CGRectMake(20, 76, 280, 364)];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
						   forView:TransitionScrollTopPaid
							 cache:YES];
	[UIView commitAnimations];
	[btnTopPaidAndPromoted setImage:[UIImage imageNamed:@"top-paid.png"] forState:UIControlStateNormal];
	[pool release];
	pool = nil;
}

-(void)displayDataInScrollView:(NSMutableArray*)array{

	UIButton *btnReedeem,*btnMain;
	//UIImageView *imgView,
	UIImageView *imgStatus;
	UILabel *lblTitle,*lblNo,*lblStatus;
	float x = 5;
	float y = 12;
	NSInteger count=0;
	CGFloat scrContentHeight;

	NSLog(@"ScrollView Subview Count :- %d",[[scrollView subviews] count]);
	if ([[scrollView subviews] count]>0) {
		for(UIView *subview in [scrollView subviews]) {
			[subview removeFromSuperview];
		}
	}
	NSLog(@"ScrollView Subview After Remove Count :- %d",[[scrollView subviews] count]);		
	for(NSInteger i=0; i<[array count]; i++) {
		btnReedeem = [UIButton buttonWithType:UIButtonTypeCustom];

		if(count == 0)
			x = 16;
		else if(count == 1)
			x = 160;
		else if(count == 2)
			x = 190;

		lblNo = [[UILabel alloc] init];
		lblNo.frame = CGRectMake(x, y, 15, 15);
		lblNo.font =[UIFont systemFontOfSize:12];
		lblNo.backgroundColor = [UIColor clearColor];
		lblNo.text = [NSString stringWithFormat:@"%d.",i+1];		
		
		UIImageView* imgView = [[UIImageView alloc] init];
		imgView.contentMode = UIViewContentModeScaleAspectFill;
		imgView.frame = CGRectMake(lblNo.frame.origin.x+lblNo.frame.size.width+2, y, 65, 65);			
		NSData *data = [[[array objectAtIndex:i] objectForKey:@"application_info"] objectForKey:@"image"];
		imgView.image = [[UIImage alloc] initWithData:data];
		
		btnMain  = [UIButton buttonWithType:UIButtonTypeCustom];
		btnMain.frame = CGRectMake(lblNo.frame.origin.x+lblNo.frame.size.width+2, y, 65, 65);

		btnMain.tag = i; //i+2001;
		[btnMain addTarget:self action:@selector(btnMainImageClick:) forControlEvents:UIControlEventTouchUpInside];
		[btnMain showsTouchWhenHighlighted];
		
		int nRedeemStatus = [[[[array objectAtIndex:i] objectForKey:@"application_info"] objectForKey:@"redeem_status"] intValue];
		if(nRedeemStatus != 2) { // Already redeemed
			imgStatus = [[UIImageView alloc] init];
			imgStatus.frame = CGRectMake(lblNo.frame.origin.x+lblNo.frame.size.width+2, y, 31, 31);			
			imgStatus.image = [UIImage imageNamed:@"Home_Credit.png"];
			
			lblStatus = [[UILabel alloc] init];
			lblStatus.frame = CGRectMake(x, y+btnMain.frame.size.height+1, 8, 11);
			lblStatus.font = [UIFont fontWithName:@"Arial" size:11];
			lblStatus.textAlignment = UITextAlignmentCenter;
			[lblStatus setBackgroundColor:[UIColor clearColor]];
			lblStatus.text = [[[array objectAtIndex:i] objectForKey:@"application_info"] objectForKey:@"points"];
		}
		
		lblTitle = [[UILabel alloc] init];
		lblTitle.frame = CGRectMake(x, y+btnMain.frame.size.height+3, 60, 20);
		lblTitle.font = [UIFont fontWithName:@"Arial" size:10];
		lblTitle.textAlignment = UITextAlignmentCenter;
		lblTitle.numberOfLines = 2;
		lblTitle.lineBreakMode = UILineBreakModeWordWrap;
		[lblTitle setBackgroundColor:[UIColor clearColor]];
		lblTitle.text = [[[array objectAtIndex:i] objectForKey:@"application_info"] objectForKey:@"app_name"];
		
		btnReedeem.frame = CGRectMake(x-5, y+btnMain.frame.size.height+ lblTitle.frame.size.height+3, 61, 23);
		btnReedeem.tag = i;
		[btnReedeem addTarget:self action:@selector(btnRedeemServiceClick:) forControlEvents:UIControlEventTouchUpInside];
		
		if ([[[[array objectAtIndex:i] objectForKey:@"application_info"] objectForKey:@"redeem_status"] intValue]== 0) {
			[btnReedeem setImage:[UIImage imageNamed:@"redeem2.png"] forState:UIControlStateNormal];
			btnReedeem.hidden = YES;
			[btnReedeem setEnabled:FALSE];
		}
		else if ([[[[array objectAtIndex:i] objectForKey:@"application_info"] objectForKey:@"redeem_status"] intValue]== 1) { // Not redeemeded , but can be
			[btnReedeem setImage:[UIImage imageNamed:@"redeem.png"] forState:UIControlStateNormal];
		}
		else if ([[[[array objectAtIndex:i] objectForKey:@"application_info"] objectForKey:@"redeem_status"] intValue]== 2) { // Already redeemed
			[btnReedeem setImage:[UIImage imageNamed:@"already_redeem.png"] forState:UIControlStateNormal];			
		}		
		[scrollView addSubview:btnReedeem];
	
		NSInteger points = [[[[array objectAtIndex:i] objectForKey:@"application_info"] objectForKey:@"points"] intValue];
		CGFloat lblNoWidth,lblStatusWidth,lblMinus;
		if (i==9) {
		    lblNoWidth=17.0;
		}else {
			lblNoWidth=10.0;
		}
		
		if (points<10) {
			lblStatusWidth=8;
			lblMinus = -12;
		}else if (points<100) {
			lblStatusWidth=20;
			lblMinus = -6;
		}else if (points<1000) {
			lblStatusWidth=20;
			lblMinus = -5;
		}

		lblNo.frame = CGRectMake(x, y, lblNoWidth, 15);	
		//imgView.frame = CGRectMake(x, y, 55, 55);	
		
		
		lblTitle.frame = CGRectMake(x+18, y+btnMain.frame.size.height+2, 60, 25);
		btnReedeem.frame = CGRectMake(x+18, y+btnMain.frame.size.height+ lblTitle.frame.size.height+4, 61, 23);
		
		if (isTopPaidFlag) {
			[scrollView addSubview:lblNo];
		}
		[lblNo release];
		
		//[scrollView addSubview:imgView];
		//[imgView release];
		[scrollView addSubview:imgView];
		[scrollView addSubview:btnMain];
		
		if(nRedeemStatus != 2) { // Already redeemed
			imgStatus.frame = CGRectMake(btnMain.frame.origin.x+btnMain.frame.size.width - 20, btnMain.frame.origin.y-12, 31, 31);			
			lblStatus.frame =CGRectMake(btnMain.frame.origin.x+btnMain.frame.size.width-lblMinus - 20, btnMain.frame.origin.y-1, lblStatusWidth, 11);
			[scrollView addSubview:imgStatus];
			[imgStatus release];
			
			[scrollView addSubview:lblStatus];
			[lblStatus release];			
		}		
		
		[scrollView addSubview:lblTitle];
		[lblTitle release];
		
		count++;
		if (count>1) {
			count=0;
			y=y+134;
			scrContentHeight =  btnReedeem.frame.origin.y+btnReedeem.frame.size.height;
		}
		
		/*if (i==0 && isTopPaidFlag==TRUE) {
				count=0;		
			y=y+120;
		}*/
 }	
	[scrollView setContentSize:CGSizeMake(280, scrContentHeight)];
}

-(IBAction)btnMainImageClick:(id)sender{	
	//NSLog(@"btnMainImageClick");
	if (isTopPaidFlag) {
		int nRedeemStatus = [[[[topPaidArray objectAtIndex:[sender tag]] objectForKey:@"application_info"] objectForKey:@"redeem_status"] intValue];
		if(nRedeemStatus != 2){ // If not alreay redeemed
			NSString *url = [[[topPaidArray objectAtIndex:[sender tag]] objectForKey:@"application_info"] objectForKey:@"url"];
			NSLog(@"url:%@",url);
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
		}
	}else {
		int nRedeemStatus = [[[[promotedArray objectAtIndex:[sender tag]] objectForKey:@"application_info"] objectForKey:@"redeem_status"] intValue];
		if(nRedeemStatus != 2) {
			NSString *url = [[[promotedArray objectAtIndex:[sender tag]] objectForKey:@"application_info"] objectForKey:@"url"];
			NSLog(@"url:%@",url);
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
		}
	}	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark Button Click Methods

-(IBAction)btnHomeClick:(id)sender{
	TransitionScale.alpha = 0;
	TransitionScale.transform = CGAffineTransformMakeScale(1.0,1.0);
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.4];
	TransitionScale.transform = CGAffineTransformMakeScale(0.1,0.1);
	TransitionScale.alpha = 1;	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView commitAnimations];
}

- (void)animationDidStop:(NSString*)animationID finished:(BOOL)finished context:(void *)context {
	for(UIViewController* vc in APP_DELEGATE.navController.viewControllers) {	
		if([vc.nibName isEqualToString:@"HomeViewController"]) {
			HomeViewController* homeVC = (HomeViewController*)vc;
			[APP_DELEGATE.navController popToViewController:homeVC animated:NO];		
		}		
	}
}

-(IBAction)btnTopPaidAndPromoted:(id)sender{
	if(APP_DELEGATE.netStatus == NotReachable) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Appinion" message:@"Please connect to internet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		return;
	}	
	[[ActivityIndicator sharedActivityIndicator] show];
	if (isTopPaidFlag) {
		isTopPaidFlag=FALSE;
		[NSThread detachNewThreadSelector:@selector(loadPromotedData) toTarget:self withObject:nil];
	}else {
		isTopPaidFlag=TRUE;
		[NSThread detachNewThreadSelector:@selector(loadTopPaidData) toTarget:self withObject:nil];
	}
}

-(NSMutableArray*)getServiceData:(NSString*)type{	
	NSURL* jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?action=app_list&type=%@&user_id=%d",BASE_URL,type,APP_DELEGATE.nUserID]];
		NSString *jsonData = [[NSString alloc] initWithContentsOfURL:jsonURL];
		if(jsonData == nil) {
			NSLog(@"Data NIL.....");
		}
		else { 
			SBJSON *json = [[SBJSON alloc] init];
			NSError *error = nil; 
			NSDictionary *dict = [json objectWithString:jsonData error:&error];
			if (appinionArray) {
				[appinionArray removeAllObjects];
			}
			if ([[NSString stringWithFormat:@"%@",[dict objectForKey:@"appinion"]] isEqualToString:@"<null>"]) {
				if ([[scrollView subviews] count]>0) {
					for(UIView *subview in [scrollView subviews]) {
						[subview removeFromSuperview];
					}
				}
			}else {
				[self setAppinionArray:[dict objectForKey:@"appinion"]];
				for(int i=0; i<[appinionArray count]; i++) {
					NSMutableDictionary *dict = [[appinionArray objectAtIndex:i] objectForKey:@"application_info"];
					NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",TOPPAID_PROMOTED_URL_IMAGE, [dict objectForKey:@"image"]]]];
					if(imageData != nil)
					[dict setObject:imageData forKey:@"image"];
					NSDictionary *tmpDict = [NSDictionary dictionaryWithObject:dict forKey:@"application_info"];
					[appinionArray replaceObjectAtIndex:i withObject:tmpDict];				
				}	
			}
			[[ActivityIndicator sharedActivityIndicator] hide];
		}
	return appinionArray;
}

-(IBAction)btnRedeemServiceClick:(id)sender{
	
	int nRedeemStatus;
	if (isTopPaidFlag) 
	   nRedeemStatus = [[[[topPaidArray objectAtIndex:[sender tag]] objectForKey:@"application_info"] objectForKey:@"redeem_status"] intValue];
	else
	   nRedeemStatus = [[[[promotedArray objectAtIndex:[sender tag]] objectForKey:@"application_info"] objectForKey:@"redeem_status"] intValue];

	if(nRedeemStatus == 2)
		return;
	
	UIButton *button = (UIButton*)sender;
	nRedeemItemTag = button.tag;
	NSLog(@"tag %d",nRedeemItemTag);
	NSString* strAppName = @"";
	if (isTopPaidFlag) 
		strAppName = [[[topPaidArray objectAtIndex:nRedeemItemTag] objectForKey:@"application_info"] objectForKey:@"app_name"];
	else
		strAppName = [[[promotedArray objectAtIndex:nRedeemItemTag] objectForKey:@"application_info"] objectForKey:@"app_name"];
	
	NSString* strPoints = @"";
	if (isTopPaidFlag) 
		strPoints = [[[topPaidArray objectAtIndex:nRedeemItemTag] objectForKey:@"application_info"] objectForKey:@"points"];
	else
		strPoints = [[[promotedArray objectAtIndex:nRedeemItemTag] objectForKey:@"application_info"] objectForKey:@"points"];
	
	NSString* strAlert = @"";
	strAlert = [strAlert stringByAppendingString:@"Would you like to redeem "];
	strAlert = [strAlert stringByAppendingString:strPoints];
	strAlert = [strAlert stringByAppendingString:@" credits for '"];	
	strAlert = [strAlert stringByAppendingString:strAppName];
	strAlert = [strAlert stringByAppendingString:@"'"];

	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Appinion" message:strAlert delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
	alert.tag = 4000;
	[alert show];
	[alert release];	
	
	/*UIButton *button = (UIButton*)sender;
	[[ActivityIndicator sharedActivityIndicator] show];
	NSString *strTag = [NSString stringWithFormat:@"%d",button.tag];
	[NSThread detachNewThreadSelector:@selector(loadRedeemServiceData:) toTarget:self withObject:strTag];*/
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag==1001) {
		[alertView setHidden:TRUE];
		[[ActivityIndicator sharedActivityIndicator] show];
		[NSThread detachNewThreadSelector:@selector(alertThread) toTarget:self withObject:nil];		
	}	
	else if(alertView.tag == 4000) {
		if (buttonIndex == 1) { // YES
			[[ActivityIndicator sharedActivityIndicator] show];
			NSString *strTag = [NSString stringWithFormat:@"%d",nRedeemItemTag];
			[NSThread detachNewThreadSelector:@selector(loadRedeemServiceData:) toTarget:self withObject:strTag];
		}
		else if (buttonIndex == 0) { // NO
			
		}
	}
}


-(void)loadRedeemServiceData:(NSString*)button{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	if (isTopPaidFlag) {
		[self redeemServiceData:[topPaidArray objectAtIndex:[button intValue]]];
	}else {
		[self redeemServiceData:[promotedArray objectAtIndex:[button intValue]]];
	}
	[pool release];
	pool = nil;
}

-(void)redeemServiceData:(NSDictionary*)dictionary{
	NSLog(@"points  %@",[NSString stringWithFormat:@"%@",[[dictionary objectForKey:@"application_info"]objectForKey:@"points"]]);
	NSURL* jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?action=save_redeem&app_id=%@&user_id=%d&points=%@",BASE_URL,[[dictionary objectForKey:@"application_info"]objectForKey:@"app_id"],APP_DELEGATE.nUserID,[[dictionary objectForKey:@"application_info"]objectForKey:@"points"]]];
	NSString *jsonData = [[NSString alloc] initWithContentsOfURL:jsonURL];
	//NSLog(jsonData);
	if(jsonData == nil) 
	{
		NSLog(@"Data NIL.....");
	}
	else { 
		SBJSON *json = [[SBJSON alloc] init];
		NSError *error = nil; 
		NSDictionary *dict = [json objectWithString:jsonData error:&error];
		NSArray *redeemArray = [dict objectForKey:@"appinion"];
		NSLog(@"Sent Redeem Message Appinion %@",[[redeemArray objectAtIndex:0] objectForKey:@"message"]);	
		if([[[redeemArray objectAtIndex:0] objectForKey:@"message"] isEqualToString:@"Fail"]) {
			NSLog(@"Fail in if");
			[[ActivityIndicator sharedActivityIndicator] hide];
		}else{
			NSString* strCodeURL = [[redeemArray objectAtIndex:0] objectForKey:@"code"];	
			strCodeURL = [strCodeURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			NSURL * URL = [NSURL URLWithString:strCodeURL];
			[[UIApplication sharedApplication] openURL:URL];
			[[ActivityIndicator sharedActivityIndicator] show];
			[NSThread detachNewThreadSelector:@selector(alertThread) toTarget:self withObject:nil];		

			/*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Thank you for redeeming points. You will have received an email with redemption information" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			alert.tag=1001;
			[alert release];*/
		}
	}	
}


-(void)alertThread{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	if (isTopPaidFlag) {
		[topPaidArray removeAllObjects];
		[self setTopPaidArray:[self getServiceData:@"paid"]];
		[self displayDataInScrollView:topPaidArray];
	}else {
		[promotedArray removeAllObjects];
		[self setTopPaidArray:[self getServiceData:@"promoted"]];
		[self displayDataInScrollView:promotedArray];
	}
	[pool release];
	pool = nil;	
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
