//
//  SelectCountryViewCountry.m
//  Appinion
//
//  Created by Sunil Adhyaru on 04/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SelectCountryViewCountry.h"


@implementation SelectCountryViewCountry

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
	btnSelect.hidden = YES;
	btnBack.hidden = NO;
	lblTitle.text = @"Select Country";
	nCurrentList = CURRENT_LIST_COUNTRY;
	[self createAlphabeticalwiseArray];
	[tblViewCountryList reloadData];
}

-(IBAction)OnButtonSelect:(id)sender {
	[APP_DELEGATE.navController popViewControllerAnimated:YES];
}

-(IBAction)OnButtonBack:(id)sender {
	if(nCurrentList == CURRENT_LIST_STATE) {
		APP_DELEGATE.strSelectedCountry = @"";
		APP_DELEGATE.strSelectedCountryID = @"";
		APP_DELEGATE.strSelectedState = @"";
		APP_DELEGATE.strSelectedStateID = @"";
		
		btnSelect.hidden = YES;
		btnBack.hidden = NO;

		nCurrentList = CURRENT_LIST_COUNTRY;
		[self createAlphabeticalwiseArray];
		[tblViewCountryList reloadData];
        NSIndexPath * ndxPath= [NSIndexPath indexPathForRow:0 inSection:0];
        [tblViewCountryList scrollToRowAtIndexPath:ndxPath atScrollPosition:UITableViewScrollPositionTop  animated:NO];
		lblTitle.text = @"Select Country";

	}
	else if(nCurrentList == CURRENT_LIST_CITY) {
		APP_DELEGATE.strSelectedState = @"";
		APP_DELEGATE.strSelectedStateID = @"";
		APP_DELEGATE.strSelectedCity = @"";
		APP_DELEGATE.strSelectedCityID = @"";
		btnSelect.hidden = YES;
		btnBack.hidden = NO;
		nCurrentList = CURRENT_LIST_STATE;
		[self createAlphabeticalwiseArray];
		[tblViewCountryList reloadData];	
		NSIndexPath * ndxPath= [NSIndexPath indexPathForRow:0 inSection:0];
        [tblViewCountryList scrollToRowAtIndexPath:ndxPath atScrollPosition:UITableViewScrollPositionTop  animated:NO];
		lblTitle.text = @"Select State";
	}
	else if(nCurrentList == CURRENT_LIST_COUNTRY) {
		[APP_DELEGATE.navController popViewControllerAnimated:YES];
	}

}

-(void)createAlphabeticalwiseArray {
	if(listOfItems)
		[listOfItems removeAllObjects];
	else
		listOfItems = [[NSMutableArray alloc] init];
	
	for(int i=0; i<26; i++) {
		char characterCodeInASCII = i+65;
		NSString *stringWithAInIt = [[NSString alloc] initWithBytes:&characterCodeInASCII length:1 encoding:NSASCIIStringEncoding];
		NSMutableArray* arrTemp = [[NSMutableArray alloc] init];
		NSMutableDictionary* dictTemp = [NSMutableDictionary dictionaryWithObject:arrTemp forKey:stringWithAInIt];		
		[arrTemp release];
		[listOfItems addObject:dictTemp];
		//[dictTemp release];	
	}
	if(nCurrentList == CURRENT_LIST_COUNTRY) {
		for(int i = 0; i<[APP_DELEGATE.arrCountry count]; i++) {
			country* temp = [APP_DELEGATE.arrCountry objectAtIndex:i];
			NSString* strFirstLatter = [temp.strName substringToIndex:1];
			const char *myString = [strFirstLatter UTF8String];
			int nIndex = myString[0];
			if (nIndex >= 97) 
				nIndex = nIndex - 32; // handle small latter
			NSMutableDictionary* dictTemp = [listOfItems objectAtIndex:nIndex-65];
			char characterCodeInASCII = nIndex;
			NSString *stringWithAInIt = [[NSString alloc] initWithBytes:&characterCodeInASCII length:1 encoding:NSASCIIStringEncoding];
			NSMutableArray* arrTemp = [dictTemp objectForKey:stringWithAInIt];
			[arrTemp addObject:temp];
		}
	}
	if(nCurrentList == CURRENT_LIST_STATE) {
		for(int i = 0; i<[arrTempState count]; i++) {
			country* temp = [arrTempState objectAtIndex:i];
			NSString* strFirstLatter = [temp.strName substringToIndex:1];
			const char *myString = [strFirstLatter UTF8String];
			int nIndex = myString[0];
			if (nIndex >= 97) 
				nIndex = nIndex - 32; // handle small latter
			NSMutableDictionary* dictTemp = [listOfItems objectAtIndex:nIndex-65];
			char characterCodeInASCII = nIndex;
			NSString *stringWithAInIt = [[NSString alloc] initWithBytes:&characterCodeInASCII length:1 encoding:NSASCIIStringEncoding];
			NSMutableArray* arrTemp = [dictTemp objectForKey:stringWithAInIt];
			[arrTemp addObject:temp];
		}
	}
	if(nCurrentList == CURRENT_LIST_CITY) {
		for(int i = 0; i<[arrTempCity count]; i++) {
			country* temp = [arrTempCity objectAtIndex:i];
			NSString* strFirstLatter = [temp.strName substringToIndex:1];
			const char *myString = [strFirstLatter UTF8String];
			int nIndex = myString[0];
			if (nIndex >= 97) 
				nIndex = nIndex - 32; // handle small latter
			NSMutableDictionary* dictTemp = [listOfItems objectAtIndex:nIndex-65];
			char characterCodeInASCII = nIndex;
			NSString *stringWithAInIt = [[NSString alloc] initWithBytes:&characterCodeInASCII length:1 encoding:NSASCIIStringEncoding];
			NSMutableArray* arrTemp = [dictTemp objectForKey:stringWithAInIt];
			[arrTemp addObject:temp];
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

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {    
	int nNoofSection = 0;
	NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
	for(int i=0; i<26; i++) {
		NSMutableDictionary* dictTemp = [listOfItems objectAtIndex:i];
		char characterCodeInASCII = i+65;
		NSString *stringWithAInIt = [[NSString alloc] initWithBytes:&characterCodeInASCII length:1 encoding:NSASCIIStringEncoding];
		NSMutableArray* arrTemp = [dictTemp objectForKey:stringWithAInIt];
		if([arrTemp count] > 0)
			nNoofSection++;
		else {
			[indexSet addIndex:i];
		}
		continue;
	}	
	[listOfItems removeObjectsAtIndexes:indexSet];
	nTotalSection = nNoofSection;
    return nNoofSection;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	int nRow = 0;
	NSMutableDictionary* dictTemp = [listOfItems objectAtIndex:section];
	NSMutableArray* arrTemp;
	for(int i=0; i<26; i++) {
		char characterCodeInASCII = i+65;
		NSString *stringWithAInIt = [[NSString alloc] initWithBytes:&characterCodeInASCII length:1 encoding:NSASCIIStringEncoding];
		arrTemp = [dictTemp objectForKey:stringWithAInIt];
		if([arrTemp count] > 0)
			break;		
	}
	nRow = [arrTemp count];		
	return nRow;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString* strTitle = @"";
	NSMutableDictionary* dictTemp = [listOfItems objectAtIndex:section];
	NSMutableArray* arrTemp;
	for(int i=0; i<26; i++) {
		char characterCodeInASCII = i+65;
		NSString *stringWithAInIt = [[NSString alloc] initWithBytes:&characterCodeInASCII length:1 encoding:NSASCIIStringEncoding];
		//NSLog(@"string %@",stringWithAInIt);
		arrTemp = [dictTemp objectForKey:stringWithAInIt];
		if([arrTemp count] > 0){
			strTitle = stringWithAInIt;
			break;		
		}
	}
	return strTitle;	
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	[tempArray addObject:@"A"];
	[tempArray addObject:@"B"];
	[tempArray addObject:@"C"];
	[tempArray addObject:@"D"];
	[tempArray addObject:@"E"];
	[tempArray addObject:@"F"];
	[tempArray addObject:@"G"];
	[tempArray addObject:@"H"];
	[tempArray addObject:@"I"];
	[tempArray addObject:@"J"];
	[tempArray addObject:@"K"];
	[tempArray addObject:@"L"];
	[tempArray addObject:@"M"];
	[tempArray addObject:@"N"];
	[tempArray addObject:@"O"];
	[tempArray addObject:@"P"];
	[tempArray addObject:@"Q"];
	[tempArray addObject:@"R"];
	[tempArray addObject:@"S"];
	[tempArray addObject:@"T"];
	[tempArray addObject:@"U"];
	[tempArray addObject:@"V"];
	[tempArray addObject:@"W"];
	[tempArray addObject:@"X"];
	[tempArray addObject:@"Y"];
	[tempArray addObject:@"Z"];
	return tempArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	int nIndex = 0;
	NSMutableArray* arrTemp;
	for(int i=0; i<[listOfItems count]; i++) {
		NSMutableDictionary* dictTemp = [listOfItems objectAtIndex:i];
		arrTemp = [dictTemp objectForKey:title];
		if([arrTemp count] > 0) {
			nIndex = i;
			break;
		}		
	}
	return nIndex;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	NSMutableDictionary* dictTemp = [listOfItems objectAtIndex:indexPath.section];
	NSMutableArray* arrTemp;
	for(int i=0; i<26; i++) {
		char characterCodeInASCII = i+65;
		NSString* stringWithAInIt = [[NSString alloc] initWithBytes:&characterCodeInASCII length:1 encoding:NSASCIIStringEncoding];
		arrTemp = [dictTemp objectForKey:stringWithAInIt];
		if([arrTemp count] > 0){
			break;		
		}
	}
	if(nCurrentList == CURRENT_LIST_COUNTRY) {		
		country* temp = [arrTemp objectAtIndex:indexPath.row];
		cell.textLabel.text = temp.strName;
	}
	else if(nCurrentList == CURRENT_LIST_STATE) {
		state* temp = [arrTemp objectAtIndex:indexPath.row];
		cell.textLabel.text = temp.strName;
	}
	else if(nCurrentList == CURRENT_LIST_CITY) {
		city* temp = [arrTemp objectAtIndex:indexPath.row];
		cell.textLabel.text = temp.strName;
	}
	
    // Configure the cell...
    
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if(nCurrentList == CURRENT_LIST_COUNTRY) {
		[[ActivityIndicator sharedActivityIndicator] show];
		NSMutableDictionary* dictTemp = [listOfItems objectAtIndex:indexPath.section];
		NSMutableArray* arrTemp;
		for(int i=0; i<26; i++) {
			char characterCodeInASCII = i+65;
			NSString* stringWithAInIt = [[NSString alloc] initWithBytes:&characterCodeInASCII length:1 encoding:NSASCIIStringEncoding];
			arrTemp = [dictTemp objectForKey:stringWithAInIt];
			if([arrTemp count] > 0){
				break;		
			}
		}
		btnSelect.hidden = YES;
		btnBack.hidden = NO;
		country* temp = [arrTemp objectAtIndex:indexPath.row];
		APP_DELEGATE.strSelectedCountry = temp.strName;
		APP_DELEGATE.strSelectedCountryID = temp.strID;
		
		// Extract state for country
		state* tempState;		
		if(!arrTempState) 
			arrTempState = [[NSMutableArray alloc] init];		
		else
			[arrTempState removeAllObjects];
		for(int i=0; i<[APP_DELEGATE.arrState count]; i++) {
			tempState = [APP_DELEGATE.arrState objectAtIndex:i];
			if([temp.strID isEqualToString:tempState.strCountryID]) {
				[arrTempState addObject:tempState];
			}
		}	
		nCurrentList = CURRENT_LIST_STATE;
		[self createAlphabeticalwiseArray];
		[tblViewCountryList reloadData];
		NSIndexPath * ndxPath= [NSIndexPath indexPathForRow:0 inSection:0];
        [tblViewCountryList scrollToRowAtIndexPath:ndxPath atScrollPosition:UITableViewScrollPositionTop  animated:NO];
		lblTitle.text = @"Select State";
		[[ActivityIndicator sharedActivityIndicator] hide];
	}
	else if(nCurrentList == CURRENT_LIST_STATE) {
		[[ActivityIndicator sharedActivityIndicator] show];
		NSMutableDictionary* dictTemp = [listOfItems objectAtIndex:indexPath.section];
		NSMutableArray* arrTemp;
		for(int i=0; i<26; i++) {
			char characterCodeInASCII = i+65;
			NSString* stringWithAInIt = [[NSString alloc] initWithBytes:&characterCodeInASCII length:1 encoding:NSASCIIStringEncoding];
			arrTemp = [dictTemp objectForKey:stringWithAInIt];
			if([arrTemp count] > 0){
				break;		
			}
		}		
		btnBack.hidden = NO;
		btnSelect.hidden = NO;
		
		// Extract city for state
		state* temp = [arrTemp objectAtIndex:indexPath.row];
		city* tempCity;		
		if(!arrTempCity) 
			arrTempCity = [[NSMutableArray alloc] init];		
		else
			[arrTempCity removeAllObjects];
		for(int i=0; i<[APP_DELEGATE.arrCity count]; i++) {
			tempCity = [APP_DELEGATE.arrCity objectAtIndex:i];
			if([temp.strStateCode isEqualToString:tempCity.strStateCode]) {
				[arrTempCity addObject:tempCity];
			}
		}
		APP_DELEGATE.strSelectedState = temp.strName;
		APP_DELEGATE.strSelectedStateID = temp.strStateID;
		nCurrentList = CURRENT_LIST_CITY;
		[self createAlphabeticalwiseArray];
		[tblViewCountryList reloadData];
		NSIndexPath * ndxPath= [NSIndexPath indexPathForRow:0 inSection:0];
        [tblViewCountryList scrollToRowAtIndexPath:ndxPath atScrollPosition:UITableViewScrollPositionTop  animated:NO];
		[[ActivityIndicator sharedActivityIndicator] hide];
		lblTitle.text = @"Select City";
	}
	else if(nCurrentList == CURRENT_LIST_CITY) {
		NSMutableDictionary* dictTemp = [listOfItems objectAtIndex:indexPath.section];
		NSMutableArray* arrTemp;
		for(int i=0; i<26; i++) {
			char characterCodeInASCII = i+65;
			NSString* stringWithAInIt = [[NSString alloc] initWithBytes:&characterCodeInASCII length:1 encoding:NSASCIIStringEncoding];
			arrTemp = [dictTemp objectForKey:stringWithAInIt];
			if([arrTemp count] > 0){
				break;		
			}
		}
		btnBack.hidden = NO;
		btnSelect.hidden = NO;
		city* temp = [arrTemp objectAtIndex:indexPath.row];
		APP_DELEGATE.strSelectedCity = temp.strName;
		APP_DELEGATE.strSelectedCityID = temp.strStateCode;
	}
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
