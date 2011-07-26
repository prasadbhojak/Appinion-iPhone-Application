//
//  HomeViewController.h
//  Appinion
//
//  Created by admin on 01/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "TopPaidAndPromotedViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <QuartzCore/QuartzCore.h>

@class QuestionsViewController;


#define WEB_SERVICE_CALL_GET_QUESTION_COUNT		0
#define WEB_SERVICE_CALL_GET_TOTAL_CREDIT_COUNT 1
#define WEB_SERVICE_CALL_GET_INVITE				2

#define TIME_FOR_SHRINKING 0.61f
#define TIME_FOR_EXPANDING 0.60f
#define SCALED_DOWN_AMOUNT 0.01 


@interface HomeViewController : UIViewController<UINavigationControllerDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate> {
	IBOutlet UIButton* btnLogin;
	IBOutlet UILabel* lblQuestionCount;
	IBOutlet UILabel* lblCreditCount;	
	int nCurrentWebServiceCall;
	NSURLConnection *theConnection;					// object used to make http connection
	NSMutableData* receivedData;					// data used to collect http reponse
	NSString* strCreditCount;
	IBOutlet UIView* viewBack;						// view for background
	IBOutlet UIButton* BtnMessageME;
	NSString* randomKey;
	int buttonClicked;
	QuestionsViewController* _QuestionsViewController;
	NSString* strMessageSubjet;
	NSString* strMessageBody;
	IBOutlet UIView* animationView;

}
@property(nonatomic,retain)IBOutlet UIButton* btnLogin;
@property(nonatomic,retain)IBOutlet UILabel* lblQuestionCount;
@property(nonatomic,retain)IBOutlet UIButton* BtnMessageME;

-(IBAction)OnButtonQestions:(id)sender;
-(IBAction)OnButtonCredit:(id)sender;
-(IBAction)OnButtonLogin:(id)sender;
-(IBAction)MessageMe:(id)sender;
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
-(void)displayMailComposerSheet;//:(NSString*)user_id Key:(NSString*)keyText;
-(void)showSMSPicker;//:(NSString*)user_id Key:(NSString*)keyText;
-(void)displaySMSComposerSheet;
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result;
-(void)CreateLinkForMail;
@end
