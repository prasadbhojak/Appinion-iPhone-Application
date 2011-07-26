//
//  city.h
//  Appinion
//
//  Created by Sunil Adhyaru on 09/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface city : NSObject {
	NSString* strStateCode;		// code for the city's state
	NSString* strName;			// city Name
}

@property(nonatomic,retain)NSString* strStateCode;
@property(nonatomic,retain)NSString* strName;
@end
