//
//  country.h
//  Appinion
//
//  Created by Sunil Adhyaru on 09/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface country : NSObject {
	NSString* strID;			// ID of the country
	NSString* strName;			// country Name
}
@property(nonatomic,retain)NSString* strID;
@property(nonatomic,retain)NSString* strName;

@end
