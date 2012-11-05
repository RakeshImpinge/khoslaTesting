//
//  AddNewWordViewController.h
//  Dictionary
//
//  Created by haramandeep on 08/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DictionaryAppDelegate.h"
#import "SA_OAuthTwitterController.h"
#import "SA_OAuthTwitterEngine.h"
#import "MGTwitterEngine.h"
#import "Facebook.h"


@interface AddNewWordViewController : UIViewController <UITextFieldDelegate,UITextViewDelegate,FBRequestDelegate,FBSessionDelegate,SA_OAuthTwitterControllerDelegate,MGTwitterEngineDelegate> {
	UITextField *mEnterWordTextField;
	UITextView *mMeaningTextView;
	UIButton *mSubmitFacebookButton;
	UIButton *mSubmitTwitterButton;
	DictionaryAppDelegate *appDelegate;
	NSString *mFBUserName;
	NSMutableDictionary *mResponseDataDictionary;
	UIImageView *mLogoImageView;
	UILabel *mWordPhraseLabel;
	UILabel *mMeaningLabel;
	UIImageView *mAddWordImageView;
	BOOL isKeyBoardUp;
	BOOL isKeyBoardTextView;
	 

}
@property (nonatomic, retain) IBOutlet UITextField *mEnterWordTextField;
@property (nonatomic, retain) IBOutlet UITextView *mMeaningTextView;
@property (nonatomic, retain) IBOutlet UIButton *mSubmitFacebookButton;
@property (nonatomic, retain) IBOutlet UIButton *mSubmitTwitterButton;
@property (nonatomic, retain) NSString *mFBUserName;
@property (nonatomic, retain) IBOutlet 	UILabel *mWordPhraseLabel;
@property (nonatomic, retain) IBOutlet 	UILabel *mMeaningLabel;
@property (nonatomic, retain) IBOutlet 	UIImageView *mAddWordImageView;
@property (nonatomic, assign) BOOL isKeyBoardUp;
@property (nonatomic, assign) BOOL isKeyBoardTextView;








- (IBAction)submitByFaceBookButtonClicked;
- (IBAction)submitByTwitterButtonClicked;
- (NSMutableDictionary *)passDataToWebService:(NSString *)userName;
- (void)saveResponseDataToCoreDatabase;
- (void)getTwitterUserName:(NSNotification *)notificationObject;




@end
