//
//  state.h
//  Appinion
//
//  Created by Sunil Adhyaru on 09/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface state : NSObject {
	NSString* strCountryID;			// ID of the country
	NSString* strStateID;			// ID of the state
	NSString* strStateCode;			// code of the state
	NSString* strName;				// state name
}
@property(nonatomic,retain)NSString* strCountryID;
@property(nonatomic,retain)NSString* strStateID;
@property(nonatomic,retain)NSString* strStateCode;
@property(nonatomic,retain)NSString* strName;

@end
