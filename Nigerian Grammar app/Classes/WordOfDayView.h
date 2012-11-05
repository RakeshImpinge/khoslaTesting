//
//  WordOfDayView.h
//  Dictionary
//
//  Created by haramandeep on 25/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DictionaryAppDelegate.h"



@interface WordOfDayView : UIViewController {
    DictionaryAppDelegate *appDelegate;
	NSArray *mWordsArray;
	NSMutableArray *mDescArray;
	NSMutableString *mHeader;
	UITableView *mTableView;
	
}
@property (nonatomic, retain) IBOutlet UITableView *mTableView;
-(void)generateWordOfTheDay;
- (NSArray *)fetchAllRecordsFromDatabase;
@end
