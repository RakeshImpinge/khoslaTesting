//
//  WordsListView.h
//  Dictionary
//
//  Created by haramandeep on 25/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DictionaryAppDelegate.h"



@interface WordsListView : UIViewController <UITextFieldDelegate, UITextViewDelegate> {
	UITableView *mWordsTableView;
	NSArray *mWordsArray;
	NSMutableArray *mAArray;
	NSMutableArray *mBArray;
	NSMutableArray *mCArray;
	NSMutableArray *mDArray;
	NSMutableArray *mEArray;
	NSMutableArray *mFArray;
	NSMutableArray *mGArray;
	NSMutableArray *mHArray;
	NSMutableArray *mIArray;
	NSMutableArray *mJArray;
	NSMutableArray *mKArray;
	NSMutableArray *mLArray;
	NSMutableArray *mMArray;
	NSMutableArray *mNArray;
	NSMutableArray *mOArray;
	NSMutableArray *mPArray;
	NSMutableArray *mQArray;
	NSMutableArray *mRArray;
	NSMutableArray *mSArray;
	NSMutableArray *mTArray;
	NSMutableArray *mUArray;
	NSMutableArray *mVArray;
	NSMutableArray *mWArray;
	NSMutableArray *mXArray;
	NSMutableArray *mYArray;
	NSMutableArray *mZArray;
	NSMutableArray *allAlphabetArray;
	DictionaryAppDelegate *appDelegate;
	NSMutableArray *mHeaderArray;
	//IBOutlet UIView *mDetailView;
	//IBOutlet UILabel *mViewNameLabel;
	//IBOutlet UILabel *mViewDescLabel;
	//BOOL type;
	NSInteger rowCount;
	//UIActivityIndicatorView *spinner;
	NSMutableArray *descArray;
	//IBOutlet UIButton *mRefreshButton;
	 //IBOutlet UIImageView *mWordListImageView;
	NSMutableString *header;

}
//@property (nonatomic, retain) NSInteger rowCount;
@property (nonatomic, retain) NSMutableArray *descArray;
@property (nonatomic, retain) IBOutlet UITableView *mWordsTableView;
@property (nonatomic, retain) NSMutableArray *mHeaderArray;


//@property (nonatomic, retain) NSMutableString *header; 
-(void) createDifferentArray;
- (NSArray *) fetchAllRecordsFromDatabase;
//-(IBAction) refreshClicked;



@end
