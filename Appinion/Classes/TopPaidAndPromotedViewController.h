//
//  TopPaidAndPromotedViewController.h
//  Appinion
//
//  Created by ripalvyas on 03/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "defines.h"
#import "JSON.h"

@interface TopPaidAndPromotedViewController : UIViewController {
	IBOutlet UIButton *btnHome;
	IBOutlet UIButton *btnTopPaidAndPromoted;
	IBOutlet UIScrollView *scrollView;
	IBOutlet UIButton* btnTopPaid;
	IBOutlet UIButton* btnPromoted;	
	BOOL isTopPaidFlag;	
	NSMutableArray *topPaidArray;
	NSMutableArray *promotedArray;
	NSMutableArray *appinionArray;
	BOOL bToppaidCallFromViewLoad;
	int nRedeemItemTag ;
	IBOutlet UIView* TransitionScrollTopPaid;
	IBOutlet UIView* TransitionScale;
}

@property(nonatomic,readwrite)BOOL isTopPaidFlag;
@property(nonatomic,retain)NSMutableArray *topPaidArray;
@property(nonatomic,retain)NSMutableArray *promotedArray;
@property(nonatomic,retain)NSMutableArray *appinionArray;


-(IBAction)btnHomeClick:(id)sender;
-(IBAction)btnTopPaidAndPromoted:(id)sender;
-(NSMutableArray*)getServiceData:(NSString*)type;
-(void)displayDataInScrollView:(NSMutableArray*)array;
-(IBAction)btnRedeemServiceClick:(id)sender;
-(void)redeemServiceData:(NSDictionary*)dictionary;
-(IBAction)OnButtonTopPaid:(id)sender;
-(IBAction)OnButtonPromoted:(id)sender;

@end
