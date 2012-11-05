//
//  DictionaryAppDelegate.m
//  Dictionary
//
//  Created by haramandeep on 25/02/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "DictionaryAppDelegate.h"
#import "SearchView.h"
#import "WordOfDayView.h"
#import "WordsListView.h"
#import "XPathQuery.h"
#import "WordList.h"
#import "Description.h"
#import "AboutView.h"
#import "AddWord.h"
#import "AddNewWordViewController.h"
#import "NSString+SBJSON.h"
#import "SA_OAuthTwitterEngine.h"
#import "MGTwitterEngineGlobalHeader.h"
#import "MGTwitterHTTPURLConnection.h"
#import "MGTwitterEngine.h"
#define kOAuthConsumerKey		@"d3IGHYiiyDm99gVhNsxWEw"		// Replace these with your consumer key 
#define	kOAuthConsumerSecret	@"o41y6W9RGaC2hYxYeBUQzkUszOdJwoon1YsBU9f88"		// and consumer secret from 


@implementation DictionaryAppDelegate

@synthesize window;
@synthesize mFacebook;
@synthesize _engine;
@synthesize mTwitterUserName;
@synthesize mCurrentActiveViewController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{    
    // Override point for customization after app launch    
	[self createTabBar];
	mServerIDArray = [[NSMutableArray alloc] init];
	responseServerDictionary = [[NSMutableDictionary alloc] init];
	mFacebook = [[Facebook alloc] init];
	_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
	_engine.consumerKey = kOAuthConsumerKey;
	_engine.consumerSecret = kOAuthConsumerSecret;
	
	hostReach = [[Reachability reachabilityForInternetConnection] retain];
	[self updateInterfaceWithReachability: hostReach];
	[self fetchWordsDataFromCoreData];
    [window makeKeyAndVisible];
}

- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
	if(netStatus == NotReachable){
			UIAlertView *connectionAlert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Please connect to a wifi or cellular network for keeping the Dictionary upto date" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			[connectionAlert show];
			[connectionAlert release];
	}
	else {
		[self loadingData];
	}
}

#pragma mark-
#pragma mark fetch WordsData FromCoreData

- (void)fetchWordsDataFromCoreData {
	NSFetchRequest *objFetchRequest = [[NSFetchRequest alloc] init];
	NSError *objError = nil;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"AddWord"
											  inManagedObjectContext:self.managedObjectContext];
    [objFetchRequest setEntity:entity];
	NSArray *mFetchServerIDArray = [self.managedObjectContext executeFetchRequest:objFetchRequest error:&objError];
	[objFetchRequest release];
	for(AddWord *addWordentityObject in mFetchServerIDArray) {
		[mServerIDArray addObject:[addWordentityObject valueForKey:@"ServerID"]];
	}
	responseServerDictionary = [self fetchServerIDDataFromWebService];
	[self deleteDataFromCoreDataBase:responseServerDictionary];
}

- (NSMutableDictionary *)fetchServerIDDataFromWebService {
	/*
http://nile.impingesolutions.com/Others/admin.nigeriangrammar.com/public_html/confirmation.php?jsonStatus=<jsonString>
	
	jsonString = { "id": "46,45,47"} */
	NSMutableDictionary *resultDict = nil;
		
	NSMutableDictionary *idDictionary = [[NSMutableDictionary alloc] init];
	[idDictionary setObject:mServerIDArray forKey:@"id"];
	NSString *idString = [idDictionary JSONRepresentation];
	NSString *serverIDString = [idString stringByReplacingOccurrencesOfString:@"[" withString:@"\""];
	serverIDString = [serverIDString stringByReplacingOccurrencesOfString:@"]" withString:@"\""];
	NSString *requestUrlString = [[NSString alloc] initWithFormat:@"http://nile.impingesolutions.com/Others/admin.nigeriangrammar.com/public_html/confirmation.php"];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[requestUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [requestUrlString release];
	NSString *requestBody = [NSString stringWithFormat:@"jsonStatus=%@",serverIDString];
	
	NSData *postBody = [requestBody dataUsingEncoding:NSUTF8StringEncoding];
	NSString *postLength = [NSString stringWithFormat:@"%d",[postBody length]];
	[urlRequest setHTTPBody:postBody];
	//[urlRequest addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-type"];
	[urlRequest addValue:postLength forHTTPHeaderField:@"Content-length"];
	[urlRequest setHTTPMethod:@"POST"];
	
	NSURLResponse *response;
	NSError *error;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
	
	if([responseData length] == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"server not responding, please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else {	   
		NSString *dataStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
		NSArray *responseArray = [dataStr JSONValue];
		if ([responseArray count]) {
			resultDict = (NSMutableDictionary *)responseArray;
		}
		
	}
	return resultDict;
	
}

- (void)deleteDataFromCoreDataBase:(NSMutableDictionary *)dictionaryReturn {
	for(int indexCount = 0; indexCount< [dictionaryReturn count]; indexCount++) {
		if([[[dictionaryReturn valueForKey:@"status"]objectAtIndex:indexCount]intValue] == 1 ||[[[dictionaryReturn valueForKey:@"status"]objectAtIndex:indexCount]intValue] == 2) {
			
			if([[[dictionaryReturn valueForKey:@"status"] objectAtIndex:indexCount]intValue] == 1) {
				NSMutableDictionary *wordDictionary = [[NSMutableDictionary alloc] init];
				[wordDictionary setObject:[[dictionaryReturn valueForKey:@"word"]objectAtIndex:indexCount] forKey:@"WORD"];
				[wordDictionary setObject:[[dictionaryReturn valueForKey:@"description"]objectAtIndex:indexCount] forKey:@"DESCRIPTION"];
				[wordDictionary setObject:[[dictionaryReturn valueForKey:@"id"]objectAtIndex:indexCount] forKey:@"ID"];
				[self insertNewWordInMainCoreDatabase:wordDictionary];
				[wordDictionary release];
				wordDictionary = nil;
			}
			else if([[[dictionaryReturn valueForKey:@"status"] objectAtIndex:indexCount]intValue] == 2) {
			}
			NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"AddWord" inManagedObjectContext:self.managedObjectContext];
			NSFetchRequest *request = [[NSFetchRequest alloc] init];
			[request setEntity:entityDesc];
			NSPredicate *pred = [NSPredicate predicateWithFormat:@"(ServerID = %d)", [[[dictionaryReturn valueForKey:@"id"]objectAtIndex:indexCount]intValue]];  //This is like the where condition
			[request setPredicate:pred];
			//NSManagedObject *matches = nil;
			NSError *error;
			NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:&error];
			AddWord *addWordEntityObject = [objects objectAtIndex:0];
			[self.managedObjectContext deleteObject:addWordEntityObject];
	       NSError *errorDelete = nil;
	       [self.managedObjectContext save:&errorDelete];
	        if (errorDelete) {
             	}
	        else {
	             }
			[request release];
		}
		else {
		}
    }
}
					 
- (void)insertNewWordInMainCoreDatabase:(NSMutableDictionary *)newWordDictionary {
  WordList *wordList = (WordList *)[NSEntityDescription insertNewObjectForEntityForName:@"WordList" inManagedObjectContext:self.managedObjectContext];
  wordList.title = [newWordDictionary valueForKey:@"WORD"];
  Description *des = (Description *)[NSEntityDescription insertNewObjectForEntityForName:@"Description" inManagedObjectContext:self.managedObjectContext];
  des.mId = [NSNumber numberWithInt:[[newWordDictionary valueForKey:@"ID"]intValue]];
  des.desc = [newWordDictionary valueForKey:@"DESCRIPTION"];
   des.linkedTo = wordList;
	NSError *error = nil;
	[self.managedObjectContext save:&error];
    if(error) {
	}
	else {
	}
}

-(void) loadingData
{
	[spinner startAnimating];
	[window addSubview:spinnerView];
	[self performSelector:@selector(getWords) withObject:nil afterDelay:0.1];
}

-(void)getWords{

	NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	if (![userDefault boolForKey:@"saveData"]){
		NSNumber *dateNumber = [NSNumber numberWithDouble:1268122450];
		[userDefault setObject:[dateNumber stringValue] forKey:@"lastDate"];
		[userDefault setBool:YES forKey:@"saveData"];
		[userDefault synchronize];
	}
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.admin.nigeriangrammar.com/get_xml_date.php?date=%@",[userDefault stringForKey:@"lastDate"]]]];
	[self getWordsFor:request];
}
- (void)getWordsFor:(NSURLRequest *)request{
	NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	NSDate *date = [NSDate date];
	NSTimeInterval timeInterval = [date timeIntervalSince1970];
	NSNumber *dateNumber = [NSNumber numberWithDouble:timeInterval];
	[userDefault setObject:[dateNumber stringValue] forKey:@"lastDate"];
	[userDefault synchronize];
	
	NSURLResponse *response;
	NSError *error;
	NSData *responseData;
	responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	NSString* aStr = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
	
	//NSLog(@"Response is %@",aStr);
	[aStr release];
	
	NSArray *result = [[NSArray alloc] initWithArray:PerformXMLXPathQuery(responseData, @"//words/book" )];
	if([result count] > 0)
	{
		resultsArray = [[NSMutableArray alloc] init];
		for (int i=0; i<[result count]; i++) {
			NSArray *statusChildArray = [[result objectAtIndex:i] objectForKey:@"nodeChildArray"];
			
			if([statusChildArray count] > 0){
				NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
				for (int j=0; j<[statusChildArray count]; j++) {
					if(j==0)
						[dict setValue:[[statusChildArray objectAtIndex:j] valueForKey:@"nodeContent"] forKey:[[statusChildArray objectAtIndex:j] valueForKey:@"nodeName"]];
					else{
						NSArray *statusChildArray2 = [[statusChildArray objectAtIndex:j] objectForKey:@"nodeChildArray"];
						if([statusChildArray2 count]>0)
						{
						  NSMutableArray *descArray = [[NSMutableArray alloc] init];
							for (int k = 0; k < [statusChildArray2 count];  k++) {
								if([[statusChildArray2 objectAtIndex:k] valueForKey:@"nodeContent"])
									[descArray addObject:[[statusChildArray2 objectAtIndex:k] valueForKey:@"nodeContent"]];
							}
						  [dict setValue:descArray forKey:@"des"];
						  [descArray release];
						  descArray = nil;
						}
					}

				}
				[resultsArray addObject:dict];
				[dict release];
				dict = nil;	
			}
		}
		[self saveContactsToDatabase];
	}
	[spinner stopAnimating];
	[spinnerView removeFromSuperview];
	[result release];
	//NSLog(@"%@",resultsArray);
	
	
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	[mFacebook logout:self];
	[mFacebook setAccessToken:nil];
	[_engine setClearsCookies:YES];
	
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
        } 
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	[mFacebook logout:self];
	[mFacebook setAccessToken:nil];
	[_engine setClearsCookies:YES];
    //[self saveContext];
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
	
	NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Dictionary.sqlite"];
	/*
	 Set up the store.
	 For the sake of illustration, provide a pre-populated default store.
	*/
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:storePath]) {
		NSString *defaultStorePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Dictionary.sqlite"];
		if (defaultStorePath) {
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
		}
	}
	
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];	
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
	
	NSError *error;
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }    
	
    return persistentStoreCoordinator;
	
	
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc
{
	[mCurrentActiveViewController release];
	[mTwitterUserName release];
	[mTabBarController release];
	[mFacebook release];

    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
	[mServerIDArray release];
	[responseServerDictionary release];
    [_engine release];
	[window release];
	[super dealloc];
}






#pragma mark ----------TabBar Creation..................


-(void)createTabBar
{
	mTabBarController = [[UITabBarController alloc] init];
	mTabBarController.delegate = self;
	
	SearchView *searchTabBAr = [[ SearchView alloc] initWithNibName:@"SearchView" bundle:[NSBundle mainBundle]];
	UIImage *searchImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Search-Icon-Select" ofType:@"png"]];
	searchTabBAr.tabBarItem.image = searchImage;
	[searchImage release];
	
	WordOfDayView *wordOfDayViewTAbBar = [[WordOfDayView alloc] initWithNibName:@"WordOfDayView" bundle:[NSBundle mainBundle]];
	UIImage *wordOfDayImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Grammer-Of-The-Day-Icon-Select" ofType:@"png"]];
	wordOfDayViewTAbBar.tabBarItem.image = wordOfDayImage;
	[wordOfDayImage release];
	
	WordsListView *wordslistViewTabBar = [[ WordsListView alloc] initWithNibName:@"WordsListView" bundle:[NSBundle mainBundle]];
	UIImage *wordListImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Word-List-Icon-Select" ofType:@"png"]];
	wordslistViewTabBar.tabBarItem.image = wordListImage;
	[wordListImage release];
	
	AboutView *aboutView = [[ AboutView alloc] initWithNibName:@"AboutView" bundle:[NSBundle mainBundle]];
	aboutView.title =@"About";
	UIImage *aboutImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"About1" ofType:@"png"]];
	aboutView.tabBarItem.image = aboutImage;
	[aboutImage release];
	
	AddNewWordViewController *addNewWordViewController = [[AddNewWordViewController alloc] initWithNibName:@"AddNewWordViewController" bundle:[NSBundle mainBundle]];
	addNewWordViewController.title = @"Add Word";
	UIImage *addWordImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tabImage" ofType:@"png"]];
	addNewWordViewController.tabBarItem.image = addWordImage;
	[addWordImage release];
	

	UINavigationController *wNavController = [[UINavigationController alloc] initWithRootViewController:wordslistViewTabBar];	
	wNavController.navigationBar.hidden = YES;
	
	mTabBarController.viewControllers =[ NSArray arrayWithObjects: searchTabBAr, wNavController, wordOfDayViewTAbBar,addNewWordViewController, aboutView, nil];
	
	
	[self.window addSubview:mTabBarController.view];
		
	[wNavController release];
	[searchTabBAr release];
	[wordOfDayViewTAbBar release];
	[wordslistViewTabBar release];
	[addNewWordViewController release];
	
	
}

#pragma mark -
#pragma mark Facebook delegates

#pragma mark FBLoginSession Delegates

/**
 * Called when the dialog successful log in the user
 */
- (void)fbDidLogin{
	//CreateUserVC *vc = [[CreateUserVC alloc] initWithNibName:@"CreateUserVC" bundle:nil];
	//[self.navigationController pushViewController:vc animated:YES];
	//[vc release];
}

/**
 * Called when the user dismiss the dialog without login
 */
- (void)fbDidNotLogin:(BOOL)cancelled{
	
}

/**
 * Called when the user is logged out
 */
- (void)fbDidLogout{
	
}

#pragma mark FBLoginDialog Delegates

- (void) fbDialogLogin:(NSString *) token expirationDate:(NSDate *) expirationDate{
	
}

- (void) fbDialogNotLogin:(BOOL) cancelled{
	
}

#pragma mark FBRequest Delegates

/**
 * Called just before the request is sent to the server.
 */
- (void)requestLoading:(FBRequest*)request{
	
}

/**
 * Called when the server responds and begins to send back data.
 */
- (void)request:(FBRequest*)request didReceiveResponse:(NSURLResponse*)response{
	
}

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest*)request didFailWithError:(NSError*)error{
	
}

/**
 * Called when a request returns and its response has been parsed into an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on thee format of the API response.
 */
- (void)request:(FBRequest*)request didLoad:(id)result{
	
}

/**
 * Called when a request returns a response.
 *
 * The result object is the raw response from the server of type NSData
 */
- (void)request:(FBRequest*)request didLoadRawResponse:(NSData*)data{
	
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
	[viewController viewWillAppear:YES];	
}

- (void)saveContactsToDatabase
{
	
	if( resultsArray == nil)
		return;
	
	
		for( int i = 0 ; i < [resultsArray count] ; i++ )
		
	{
		WordList *wordList = (WordList *)[NSEntityDescription insertNewObjectForEntityForName:@"WordList" inManagedObjectContext:self.managedObjectContext];

		wordList.title = [[resultsArray objectAtIndex:i]valueForKey:@"title"];
		
		
		NSArray *desArray = [[NSArray alloc] initWithArray:[[resultsArray objectAtIndex:i]valueForKey:@"des"]];
		for( int j=0; j<[desArray count]; j++)
		{		
			Description *des = (Description *)[NSEntityDescription insertNewObjectForEntityForName:@"Description" inManagedObjectContext:self.managedObjectContext];
			des.mId = [NSNumber numberWithInt:j];
			des.desc = [desArray objectAtIndex:j];
			des.linkedTo = wordList;
		}
		
	}	
	[resultsArray release];
	   NSError *error;
	  if(![self.managedObjectContext save:&error])
	   {
		  NSLog(@"handel error");
	   }
	
	
}

#pragma mark-
#pragma mark Twitter Delegates

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier {
	NSString *userName = [NSString stringWithFormat:@"%@",[userInfo valueForKey:@"name"]];
	userName = [userName stringByReplacingOccurrencesOfString:@"(""" withString:@" "];
	userName = [userName stringByReplacingOccurrencesOfString:@""")" withString:@" "];
	userName = [userName stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	userName = [userName stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	userName = [userName stringByReplacingOccurrencesOfString:@"\"" withString:@" "];
	userName = [userName stringByReplacingOccurrencesOfString:@"\"" withString:@" "];
	userName = [userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if ([self.mCurrentActiveViewController isEqualToString:@"SearchView"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TWITTERUSERNAME_SEARCHVIEW"
															object:userName];
	}
	else if ([self.mCurrentActiveViewController isEqualToString:@"DetailView"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TWITTERUSERNAME_DETAILVIEW"
															object:userName];
	} 
	else if ([self.mCurrentActiveViewController isEqualToString:@"AddNewWordViewController"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TWITTERUSERNAME_WORDLIST"
															object:userName];
	} 
} 

- (void) requestSucceeded: (NSString *) requestIdentifier {
	NSLog(@"Request %@ succeeded", requestIdentifier);
}

#pragma mark TwitterEngineDelegate
- (void)receivedObject:(NSDictionary *)dictionary forRequest:(NSString *)connectionIdentifier {
	NSLog(@"%@",dictionary);	
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
	NSLog(@"%@",response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //[responseData appendData:data];
	NSLog(@"%@",data);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
    // Show error
	NSLog(@"%@",error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
    // Once this method is invoked, "responseData" contains the complete result
}

- (void)connectionFinished:(NSString *)connectionIdentifier {
	
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	
	if ([[error domain] isEqualToString: @"HTTP"]) {
		
		switch ([error code]) {
				
			case 401:
			{
				NSLog(@"error is:%@",[error description]);
				// Unauthorized. The user's credentials failed to verify.
				NSLog(@"Tweet", @"Your username and password could not be verified. Double check that you entered them correctly and try again.", @"OK");	
				break;				
			}
				
			case 502:
			{
				// Bad gateway: twitter is down or being upgraded.
				NSLog(@"Tweet", @"Looks like Twitter is down or being updated. Please wait a few seconds and try again.", @"OK");	
				break;				
			}
				
			case 503:
			{
				// Service unavailable
				NSLog(@"Tweet", @"Looks like Twitter is overloaded. Please wait a few seconds and try again.", @"OK");	
				break;								
			}
				
			case 403:
			{
				//Quote repeat
				NSLog(@"Tweet", @"You have recently Tweeted this quote.  Please select another quote and try again", @"OK");
				break;
			}
				
			default:
			{
				NSString *errorMessage = [[NSString alloc] initWithFormat: @"%d %@", [error	code], [error localizedDescription]];
				NSLog(@"%@",errorMessage);	
				[errorMessage release];
				break;				
			}
		}
	}
	
}  





@end

