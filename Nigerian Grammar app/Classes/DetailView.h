//
//  DetailView.h
//  Dictionary
//
//  Created by Kanchan on 05/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordsListView.h"
#import "DictionaryAppDelegate.h"
#import "SA_OAuthTwitterController.h"
#import "SA_OAuthTwitterEngine.h"


@interface DetailView : UIViewController <FBSessionDelegate,FBRequestDelegate,SA_OAuthTwitterControllerDelegate> {
	UITableView *mDetailTableView;
	NSMutableArray *mDescArray;
    WordsListView *wordList;
	NSMutableString *mHeader;
	IBOutlet UIButton *mBackButton;
	UIButton *mFacebookShareButton;
	UIButton *mTwitterShareButton;
	DictionaryAppDelegate *appDelegate;
	NSString *mFacebookTitleWordString;
	NSString *mFacebookDescriptionWordString;
	NSString *mPostWordFaceBookUserName;


	
}
@property (nonatomic, retain) IBOutlet UITableView *mDetailTableView;
@property (nonatomic, retain) NSMutableArray *mDescArray;
@property (nonatomic, retain) NSMutableString *mHeader;
@property (nonatomic, retain) IBOutlet UIButton *mFacebookShareButton;
@property (nonatomic, retain) IBOutlet UIButton *mTwitterShareButton;
@property (nonatomic, retain) NSString *mPostWordFaceBookUserName;



-(IBAction) backClicked;
- (IBAction)facebookShareButtonClicked;
- (IBAction)twitterShareButtonClicked;

@end
