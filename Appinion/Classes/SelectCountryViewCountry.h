//
//  SelectCountryViewCountry.h
//  Appinion
//
//  Created by Sunil Adhyaru on 04/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "defines.h"

#define CURRENT_LIST_COUNTRY	0
#define CURRENT_LIST_STATE		1	
#define CURRENT_LIST_CITY		2

@interface SelectCountryViewCountry : UIViewController {
	IBOutlet UITableView* tblViewCountryList;	// table view
	IBOutlet UILabel* lblTitle;					// title label
	int nCurrentList;							// current list (city, country or state)
	NSMutableArray* listOfItems;				
	int nTotalSection;							// total section
	IBOutlet UIButton* btnSelect;				// button select
	IBOutlet UIButton* btnBack;					// button back
	NSMutableArray* arrTempState;				// temp array for state;
	NSMutableArray* arrTempCity;				// temp array for city;		
}
-(IBAction)OnButtonSelect:(id)sender;
-(IBAction)OnButtonBack:(id)sender;

-(void)createAlphabeticalwiseArray;

@end
