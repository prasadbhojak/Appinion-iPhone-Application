//
//  InfoViewController.h
//  Appinion
//
//  Created by Sunil Adhyaru on 02/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "defines.h"
#import "AppinionAppDelegate.h"

@interface InfoViewController : UIViewController {
	IBOutlet UITextView* txtInfo;
}

-(IBAction)OnButtonBack:(id)sender;
@end
