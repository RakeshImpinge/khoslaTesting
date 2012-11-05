//
//  SearchView.h
//  Dictionary
//
//  Created by haramandeep on 25/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DictionaryAppDelegate.h"
#import "SA_OAuthTwitterController.h"
#import "SA_OAuthTwitterEngine.h"

#define kCachedXAuthAccessTokenStringKey	@"cachedXAuthAccessTokenKey"



@interface SearchView : UIViewController <UITableViewDelegate , UITableViewDataSource, UISearchBarDelegate,FBRequestDelegate,FBSessionDelegate,FBDialogDelegate,SA_OAuthTwitterControllerDelegate>
{
	UISearchBar *mSearchBar;
	UITableView *mTableView;
	NSMutableArray *mDummyArray; 
	NSArray *mWordsArray;
	DictionaryAppDelegate *appDelegate;
	IBOutlet UIView *mDetailView;
	IBOutlet UILabel *mViewNameLabel;
	IBOutlet UILabel *mViewDescLabel;
	IBOutlet UIImageView *mBackground;
	BOOL type;
	NSMutableString *mHeader;
	NSInteger rowCount;
	NSMutableArray *descArray;
	IBOutlet UIButton *mCancelButton;
	NSString *mHeaderString;
	NSString *mFacebookTitleWordString;
	NSString *mFacebookDescriptionWordString;
	NSString *mPostWordFaceBookUserName;
	


}
@property (nonatomic, retain) IBOutlet UISearchBar *mSearchBar;
@property (nonatomic, retain) IBOutlet UITableView *mTableView;
@property (nonatomic, retain) NSString *mPostWordFaceBookUserName;

//@property (nonatomic, retain) NSMutableArray *mWordsArray;
//@property (nonatomic, retain) 
//-(void)createDummyData;
- (void) searchWordsArray;
- (NSArray *)fetchAllRecordsFromDatabase;
-(IBAction)cancelClicked;
- (IBAction)facebookShareButtonClicked;
- (IBAction)twitterShareButtonClicked;
- (void)getTwitterUserName:(NSNotification *)notificationObject;



@end
