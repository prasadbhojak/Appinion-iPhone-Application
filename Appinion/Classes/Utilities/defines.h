//
//  defines.h
//  SeniorLiving
//
//  Created by Sunil Adhyaru on 20/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppinionAppDelegate.h"

#define APP_DELEGATE ((AppinionAppDelegate*)[[UIApplication sharedApplication] delegate])
#define APP_DELEGATE_WINDOW ((UIWindow*)((SeniorLivingAppDelegate*)[[UIApplication sharedApplication] delegate])).window

//local
/*#define BASE_URL					@"http://192.168.3.113/appinion/iphone/webservice.php"
#define BASE_URL_BRAND_IMAGE		@"http://192.168.3.113/appinion/images/survey_brand/"
#define BASE_URL_ANSWER_IMAGE		@"http://192.168.3.113/appinion/images/answer_image/"
#define HOST_NAME					@"http://192.168.3.113/appinion/iphone/"
#define TOPPAID_PROMOTED_URL_IMAGE  @"http://192.168.3.113/appinion/images/credit_app_images/"*/

//live
/*#define BASE_URL					@"http://softwebdemo.com/viral/appinion/iphone/webservice.php"
#define BASE_URL_BRAND_IMAGE		@"http://softwebdemo.com/viral/appinion/images/survey_brand/"
#define BASE_URL_ANSWER_IMAGE		@"http://softwebdemo.com/viral/appinion/images/answer_image/"
#define HOST_NAME					@"http://softwebdemo.com/viral/appinion/iphone/"
#define TOPPAID_PROMOTED_URL_IMAGE  @"http://softwebdemo.com/viral/appinion/images/credit_app_images/"*/

//live client
#define BASE_URL					@"http://www.appinion.com/demo/iphone/webservice.php"
#define BASE_URL_BRAND_IMAGE		@"http://www.appinion.com/demo/images/survey_brand/"
#define BASE_URL_ANSWER_IMAGE		@"http://www.appinion.com/demo/images/answer_image/"
#define HOST_NAME					@"http://www.appinion.com/demo/iphone/"
#define TOPPAID_PROMOTED_URL_IMAGE  @"http://www.appinion.com/demo/images/credit_app_images/"

