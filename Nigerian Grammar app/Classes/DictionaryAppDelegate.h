//
//  DictionaryAppDelegate.h
//  Dictionary
//
//  Created by haramandeep on 25/02/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//
#import "Reachability.h"
#import "Facebook.h"
#import "SA_OAuthTwitterController.h"
#import "MGTwitterEngine.h"

@class SA_OAuthTwitterEngine;



@interface DictionaryAppDelegate : NSObject <UIApplicationDelegate ,UITabBarControllerDelegate,FBSessionDelegate,SA_OAuthTwitterControllerDelegate,MGTwitterEngineDelegate> 
{
    
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	Reachability* hostReach;
	IBOutlet UIActivityIndicatorView *spinner;
	IBOutlet UIView *spinnerView;
	Facebook *mFacebook;
    UIWindow *window;
	UITabBarController * mTabBarController;
	NSMutableArray *resultsArray;
	BOOL type;
	NSMutableArray *mServerIDArray;
	NSMutableDictionary *responseServerDictionary;
	SA_OAuthTwitterEngine *_engine;
	NSString *mTwitterUserName;
	NSString *mCurrentActiveViewController;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) Facebook *mFacebook;
@property (nonatomic,retain) SA_OAuthTwitterEngine *_engine;
@property (nonatomic, retain) NSString *mTwitterUserName;
@property (nonatomic, retain) NSString *mCurrentActiveViewController;


@property (nonatomic, retain) IBOutlet UIWindow *window;

- (void) updateInterfaceWithReachability: (Reachability*) curReach;

- (NSString *)applicationDocumentsDirectory;
-(void)createTabBar;
-(void)getWords;
- (void)getWordsFor:(NSURLRequest *)request;
- (void)saveContactsToDatabase;
-(void) loadingData;
- (void)fetchWordsDataFromCoreData;
- (NSMutableDictionary *)fetchServerIDDataFromWebService;
- (void)deleteDataFromCoreDataBase:(NSMutableDictionary *)dictionaryReturn;
- (void)insertNewWordInMainCoreDatabase:(NSMutableDictionary *)newWordDictionary;



@end

