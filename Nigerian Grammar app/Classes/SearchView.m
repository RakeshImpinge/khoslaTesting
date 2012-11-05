//
//  SearchView.m
//  Dictionary
//
//  Created by haramandeep on 25/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SearchView.h"
#import "WordList.h"
#import "SA_OAuthTwitterEngine.h"
#import "MGTwitterEngineGlobalHeader.h"
#import "MGTwitterHTTPURLConnection.h"
#import "Description.h"
#define kOAuthConsumerKey		@"d3IGHYiiyDm99gVhNsxWEw"		// Replace these with your consumer key 
#define	kOAuthConsumerSecret	@"o41y6W9RGaC2hYxYeBUQzkUszOdJwoon1YsBU9f88"		// and consumer secret from 



@implementation SearchView
@synthesize mSearchBar;
@synthesize mTableView;
@synthesize mPostWordFaceBookUserName;
//@synthesize mWordsArray;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
	{
        // Custom initialization
		self.title =@"Search";
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTwitterUserName:) name:@"TWITTERUSERNAME_SEARCHVIEW" object:nil];
	//appDelgate._engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
//	appDelgate._engine.consumerKey = kOAuthConsumerKey;
//	appDelgate._engine.consumerSecret = kOAuthConsumerSecret;
	
	mPostWordFaceBookUserName = [[NSString alloc] init];
	mDummyArray = [[NSMutableArray alloc]init];
	mTableView.backgroundColor =[UIColor clearColor]; 
	mTableView.separatorColor = [UIColor clearColor];
	mFacebookTitleWordString = [[NSString alloc] init];
	mFacebookDescriptionWordString = [[NSString alloc] init];
	type = YES;
	descArray = [[NSMutableArray alloc]init];
}


-(void)viewWillAppear: (BOOL)animated{
	if(mWordsArray)
	{
		[mWordsArray release];
		mWordsArray = nil;
	}
	[mSearchBar setText:NO];
	[mDummyArray removeAllObjects];
	[mTableView reloadData];
	mWordsArray = [[NSArray alloc]initWithArray:[self fetchAllRecordsFromDatabase]];
	
	appDelegate.mCurrentActiveViewController = NSStringFromClass([self class]);
	//NSLog(@"class is:%@",appDelegate.mCurrentActiveViewController);
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.mTableView = nil;
}


- (void)dealloc {

	[mTableView release];
	[mSearchBar release];
	[mWordsArray release];
	[mDummyArray release];
	[descArray release];
	[mFacebookTitleWordString release];
	[mFacebookDescriptionWordString release];
	[mPostWordFaceBookUserName release];
    [super dealloc];
	
}


#pragma mark --------------------------------------------------
#pragma mark SearchBar delegate Methods
#pragma mark --------------------------------------------------


- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchTexte
{   
	type = YES;
	[mDummyArray removeAllObjects];
	[self searchWordsArray];
	[mTableView reloadData];
	mTableView.frame = CGRectMake(0, 144, 320, 103);
	
	if([[mSearchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] || mSearchBar.text == nil)
	 {
		 UIImage *backGroundImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Background-Dark" ofType:@"png"]];
	     mBackground.image = backGroundImage;
		 [backGroundImage release];
	 }
	 
	 else
	 {
	   
	      mHeaderString =[NSString stringWithFormat:@"%d entries found for %@ ", [mDummyArray count],  mSearchBar.text];
		  UIImage *backGroundImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Background-Light" ofType:@"png"]];
	      mBackground.image = backGroundImage;
	      [backGroundImage release];
	 }
	
	    
	
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
	mTableView.frame = CGRectMake(0, 144, 320, 266);
	[mSearchBar resignFirstResponder];
	
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar
{
	mTableView.frame = CGRectMake(0, 144, 320, 266);
	[mSearchBar resignFirstResponder];
	[mSearchBar setText:NO];
	[mDummyArray removeAllObjects];
	//[mTableView reloadData];
 
	
	
}

- (void) searchWordsArray
{
	
	NSString *searchText = [mSearchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	searchText =[searchText uppercaseString];
	NSInteger length = [searchText length];
	if(length == 0)
		return;
	
	for(int i=0;i<[mWordsArray count];i++)
	{
		NSDictionary *dict = [mWordsArray objectAtIndex:i];
		NSString *orignalString = [dict valueForKey:@"title"];
		orignalString = [orignalString uppercaseString];
		if([orignalString length]<length)
		{
			continue;	
		}
		 else
		 {
	       NSString *tempString = [orignalString substringToIndex:length];
		
		   if([tempString isEqualToString:searchText])
		    {
			  [mDummyArray addObject:dict];
			
			}
		 }
	 }

	length = 0;
	searchText = nil;
}	
		
		
		
		



#pragma mark <------------------------------------------------------------------------->
#pragma mark   <-------  tableView Delegate and dataSource methods --------------->
#pragma mark <-------------------------------------------------------------------------->


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(type){
		return [mDummyArray count];
	}
	else 
	{
		return [descArray count]+3;
		
		
	}
	return 0;
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
	if(type){
		return 38.0;
	}
	else
	{
		if(indexPath.row == 0 || indexPath.row == 2){
			return 58;
		}
		else if(indexPath.row == 1){
			int temp = [mHeader length];
			temp=temp/24;
			temp= temp +1;
			int height =  (temp*24);
			return height;			
		}
		else
		{
			NSString *descStr;
			descStr = [descArray objectAtIndex:indexPath.row-3];
			int temp = [descStr length];
			temp=temp/32;
			temp= temp +1;
			int height =  (temp*24);
			return height;
		}
		
		
	}
	return 0;
}	
	

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	NSArray *views = [cell.contentView subviews];
	for( int i = 0; i < [views count]; i++) {
		UIView *tempView = [views objectAtIndex:i];
		[tempView removeFromSuperview];
		tempView = nil;
	}
	views = nil;
	
	cell.textLabel.text = nil;
	if(type){
	
		cell.textLabel.text = [[[mDummyArray objectAtIndex:indexPath.row]valueForKey:@"title"] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		mTableView.separatorColor = [UIColor lightGrayColor];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	
	else{
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.text = nil;
		mTableView.separatorColor = [UIColor clearColor];
		if(indexPath.row == 0)
		{
			UIImage *nameImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Word" ofType:@"png"]];
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 33, 97, 25)];
			imageView.image = nameImage;
			[cell.contentView addSubview:imageView];
			[imageView release];
			[nameImage release];
			UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
			UIImage *facebookImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Facebook-Select" ofType:@"png"]];

			facebookButton.frame = CGRectMake(185, 33, 42, 42);
			[facebookButton setBackgroundColor:[UIColor clearColor]];
			[facebookButton setImage:facebookImage forState:UIControlStateNormal]; 
			[facebookButton addTarget:self action:@selector(facebookShareButtonClicked) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:facebookButton];
			[facebookImage release]; 
			 
			UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
			UIImage *twitterImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Twitter-Select" ofType:@"png"]];
			twitterButton.frame = CGRectMake(250, 33, 40, 42);
			[twitterButton setImage:twitterImage forState:UIControlStateNormal]; 
			[twitterButton setBackgroundColor:[UIColor clearColor]];
			[twitterButton addTarget:self action:@selector(twitterShareButtonClicked) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:twitterButton];
			 [twitterImage release];
			  
			 
		}
		else if(indexPath.row == 2)
		{
			UIImage *nameImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Meaning" ofType:@"png"]];
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 30, 133, 27)];
			imageView.image = nameImage;
			[cell.contentView addSubview:imageView];
			[imageView release];
			[nameImage release];
		}
		
		
		else if(indexPath.row == 1)
		{
			cell.textLabel.numberOfLines = 5;
			cell.textLabel.text = [mHeader stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
			mFacebookTitleWordString = [mHeader stringByReplacingOccurrencesOfString:@"\n" withString:@" "];

			cell.textLabel.font = [UIFont boldSystemFontOfSize:21];
		}
		else
		{
			cell.textLabel.text =[[descArray objectAtIndex:indexPath.row-3] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
			mFacebookDescriptionWordString = [[descArray objectAtIndex:indexPath.row-3] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];

			cell.textLabel.numberOfLines = 20;
			
			cell.textLabel.font = [UIFont systemFontOfSize:16];
		}
		
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(type){
		mTableView.frame = CGRectMake(0, 144, 320, 266);

		rowCount = indexPath.row;
		[descArray removeAllObjects];
		if(mHeader){
			[mHeader release];
			mHeader = nil;
		}
		mHeader = [[NSMutableString alloc]initWithString:[[mDummyArray objectAtIndex:rowCount]valueForKey:@"title"]];
        
		NSArray *tempArray = [[[mDummyArray objectAtIndex:rowCount]valueForKey:@"des"] allObjects];
		
		
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"mId" ascending:true];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		tempArray = [tempArray sortedArrayUsingDescriptors:sortDescriptors];
		[sortDescriptor release];
		[sortDescriptors release];
		
		for (int i=0; i<[tempArray count] ; i++) {
			[descArray addObject:[[tempArray objectAtIndex:i] desc]];
		}
		
		//[descArray addObjectsFromArray:[[mDummyArray objectAtIndex:rowCount]valueForKey:@"des"]]; 
		
		
		type = NO;
		[mTableView reloadData];
		[mSearchBar resignFirstResponder];

	}
	else{
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	
	
}

#pragma mark-
#pragma mark facebook & twitterShareButtonClicked

- (IBAction)facebookShareButtonClicked {
	if (![appDelegate.mFacebook isSessionValid]) {
		[appDelegate.mFacebook authorize:@"145592028834279" permissions:[NSArray arrayWithObjects:@"offline_access", @"publish_stream", nil] delegate:self];
	}
	else {
		[self fbDidLogin];
	}
}

- (IBAction)twitterShareButtonClicked {
	NSString *wordTitleAndMeaningString = [mFacebookTitleWordString stringByAppendingString:[NSString stringWithFormat:@"\n \n%@",mFacebookDescriptionWordString]];
/*
	UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:appDelegate._engine delegate:self];
	if (controller) {
		[self presentModalViewController:controller animated:YES];
	} 
	else {
		[appDelegate._engine sendUpdate:wordTitleAndMeaningString];
	} */
	
	UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:appDelegate._engine delegate:self];
	if (controller) {
		[self presentModalViewController:controller animated:YES];
	} 
	else {
		[appDelegate._engine getUserInformationFor:[appDelegate._engine username]];
	}
}

#pragma mark-
#pragma mark FBLoginSession Delegates

/**
 * Called when the dialog successful log in the user
 */
- (void)fbDidLogin{
	//NSString *wordTitleAndMeaningString = [mFacebookTitleWordString stringByAppendingString:[NSString stringWithFormat:@"\n%@",mFacebookDescriptionWordString]];
	//XXX likes the phrase/Quote/Saying <a href='appstore link'>"PHRASE"</a> on the Nigerian Grammar PHONE_PLATFORM app. Be a part of the movement. Download yours today. Nigerian Grammar mobile app available for iPod, iPhone, iPad and Android. 
	//NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",wordTitleAndMeaningString],  @"message",nil];
	//[appDelegate.mFacebook dialog:@"feed" andParams:params andDelegate:self];
	//[appDelegate.mFacebook requestWithGraphPath:@"me" andDelegate:self];
	[appDelegate.mFacebook requestWithGraphPath:@"me?fields=name,picture,id" andDelegate:self];
	//NSLog(@"name is:%@",self.mPostWordFaceBookUserName);
	//[appDelegate.mFacebook requestWithMethodName:@"stream.publish" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

- (void)request:(FBRequest*)request didLoadRawResponse:(NSData*)data {
	if([[request url] isEqualToString:@"https://graph.facebook.com/me?fields=name,picture,id"]) {
	NSString *requestString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [requestString JSONValue];
	[requestString release];
		self.mPostWordFaceBookUserName = [dict valueForKey:@"name"];
		NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
		NSString *linkString = @"http://www.nigeriangrammar.com/downloads";
		NSString *postString = [NSString stringWithFormat:@"%@ likes the grammar \"%@\" on the Nigerian Grammar mobile app.",self.mPostWordFaceBookUserName,mFacebookTitleWordString];
		[params setObject:postString forKey:@"message"];
		[params setObject:@"Downloads | Nigeriangrammar.com" forKey:@"name"];
		[params setObject:linkString forKey:@"link"];
		[params setObject:@"http://nigeriangrammar.com/wp-content/uploads/2011/04/nigeriangrammarlogo.jpg" forKey:@"picture"];
		[params setObject:@"Your favorite Nigerian slangs, grammar and jokes. Join the movement. App available for iPhone, iPad, iPod and Android platforms" forKey:@"description"];
		[appDelegate.mFacebook requestWithGraphPath:@"me/feed" andParams:params andHttpMethod:@"POST" andDelegate:self];
	    [params release];
		params = nil;
	}
      else {
       }
   }
/**
 * Called when the user dismiss the dialog without login
 */
- (void)fbDidNotLogin:(BOOL)cancelled{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook did not login" message:@"You need to sign in to perform various actions within the app." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

#pragma mark-
#pragma mark FBRequest Delegates

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error{
	UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
	[errorAlert show];
	[errorAlert release];
}

/*
 Called just before the request is sent to the server.
 */

- (void)requestLoading:(FBRequest*)request{
}

- (void)request:(FBRequest*)request didReceiveResponse:(NSURLResponse*)response{
}

- (void)request:(FBRequest*)request didLoad:(id)result{
	if([[request url] isEqualToString:@"https://graph.facebook.com/me?fields=name,picture,id"]) {
	}
	else {
	UIAlertView *dataPostAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Word & Meaning Successfully post" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
	[dataPostAlert show];
	[dataPostAlert release];
	}
}

//=============================================================================================================================
#pragma mark TwitterEngineDelegate

- (void) requestSucceeded: (NSString *) requestIdentifier {
	UIAlertView *dataPostAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Word & Meaning Successfully post" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
	[dataPostAlert show];
	[dataPostAlert release];
	
}

#pragma mark TwitterEngineDelegate

- (void)receivedObject:(NSDictionary *)dictionary forRequest:(NSString *)connectionIdentifier {
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // Show error
}

/*
- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
} */


#pragma mark-
#pragma mark getTwitterUserName method

- (void)getTwitterUserName:(NSNotification *)notificationObject {
	self.mPostWordFaceBookUserName = (NSString *)[notificationObject object];
	//NSString *wordTitleAndMeaningString = [mFacebookTitleWordString stringByAppendingString:[NSString stringWithFormat:@"\n \n%@",mFacebookDescriptionWordString]];
	NSString *linkString = @"http://www.nigeriangrammar.com/downloads";
	NSString *postString = [NSString stringWithFormat:@"%@ likes the grammar \"%@\" on the @NigerianGrammar mobile app.%@",self.mPostWordFaceBookUserName,mFacebookTitleWordString,linkString];
	[appDelegate._engine sendUpdate:postString];
}

#pragma mark-
#pragma mark SA_OAuthTwitterControllerDelegate

- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username {
	//NSString *wordTitleAndMeaningString = [mFacebookTitleWordString stringByAppendingString:[NSString stringWithFormat:@"\n \n%@",mFacebookDescriptionWordString]];
	//[appDelegate._engine sendUpdate:@"test"];
	[appDelegate._engine getUserInformationFor:username];
	//UIAlertView *dataPostAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Word & Meaning Successfully post" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
	//[dataPostAlert show];
	//[dataPostAlert release];
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error
{
	if ([[error domain] isEqualToString: @"HTTP"])
	{
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


- (NSArray *)fetchAllRecordsFromDatabase {
	appDelegate = (DictionaryAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	NSFetchRequest * request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"WordList" inManagedObjectContext:appDelegate.managedObjectContext];
	[request setEntity: entity];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	[request setSortDescriptors:sortDescriptors];
	
	NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:request error:nil];
	[request release];
	[sortDescriptor release];
	if ([results count] > 0)
		return results;
	else {
		return nil;
	}
}
-(IBAction)cancelClicked{
	mSearchBar.text = nil;
	mTableView.frame = CGRectMake(0, 144, 320, 266);
	[mSearchBar resignFirstResponder];
	mTableView.separatorColor = [UIColor clearColor];
}


@end
