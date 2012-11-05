//
//  DetailView.m
//  Dictionary
//
//  Created by Kanchan on 05/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DetailView.h"
#import "WordsListView.h"
#import "Description.h"
#import "SA_OAuthTwitterEngine.h"
#import "MGTwitterEngineGlobalHeader.h"
#import "MGTwitterHTTPURLConnection.h"

@implementation DetailView
@synthesize mDetailTableView;
@synthesize mDescArray;
@synthesize mHeader;
@synthesize mFacebookShareButton;
@synthesize mTwitterShareButton;
@synthesize mPostWordFaceBookUserName;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	 [super viewDidLoad];
	//mDescArray = wordLIst.descArray;
	//mDescArray =[[NSMutableArray alloc] init];
	self.mPostWordFaceBookUserName = [[NSString alloc] init];
	appDelegate = (DictionaryAppDelegate*)[[UIApplication sharedApplication] delegate];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTwitterUserName:) name:@"TWITTERUSERNAME_DETAILVIEW" object:nil];

	mDetailTableView.separatorStyle = UITableViewCellSelectionStyleNone;
	mDetailTableView.backgroundColor =[UIColor clearColor]; 
	mFacebookTitleWordString = [[NSString alloc] init];
	mFacebookDescriptionWordString = [[NSString alloc] init];

	   
}

- (void)viewWillAppear:(BOOL)animated {
	appDelegate.mCurrentActiveViewController = NSStringFromClass([self class]);
	NSLog(@"class is:%@",appDelegate.mCurrentActiveViewController);	
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
	self.mDetailTableView = nil;
}


- (void)dealloc {
    
	[mDetailTableView release];
	[mDescArray release];
	[mFacebookShareButton release];
	[mTwitterShareButton release];
	[mFacebookTitleWordString release];
	[mFacebookDescriptionWordString release];
	[mPostWordFaceBookUserName release];
	//[mHeader release];
	[super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	
	return [mDescArray count]+3;
	
}
- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
	
	if(indexPath.row == 0 || indexPath.row == 2){
		return 58;
	}
	else if(indexPath.row == 1){
		int temp = [mHeader length];
		temp=temp/20;
		temp= temp +1;
		int height =  (temp*24);
		return height;
	}
		
	else
	{
		NSString *descStr;
		descStr = [mDescArray objectAtIndex:indexPath.row-3];
		int temp = [descStr length];
		temp=temp/32;
		temp= temp +1;
		int height =  (temp*24);
		return height;
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
	
	if(indexPath.row == 0)
	{
		UIImage *nameImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Word" ofType:@"png"]];
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 33, 97, 25)];
		imageView.image = nameImage;
		[cell.contentView addSubview:imageView];
		[imageView release];
		[nameImage release];
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
		cell.textLabel.font = [UIFont boldSystemFontOfSize:21];
		mFacebookTitleWordString = [mHeader stringByReplacingOccurrencesOfString:@"\n" withString:@" "];

	}
	else
	{
		cell.textLabel.text =[[mDescArray objectAtIndex:indexPath.row-3] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
		cell.textLabel.numberOfLines = 8;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.font = [UIFont systemFontOfSize:16];
		mFacebookDescriptionWordString = [[mDescArray objectAtIndex:indexPath.row-3] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];

	}
	return cell;	
	
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
	//NSString *wordTitleAndMeaningString = [mFacebookTitleWordString stringByAppendingString:[NSString stringWithFormat:@"\n \n%@",mFacebookDescriptionWordString]];
	NSString *linkString = @"http://www.nigeriangrammar.com/downloads";
	NSString *postString = [NSString stringWithFormat:@"%@ likes the grammar \"%@\" on the @NigerianGrammar mobile app.%@",self.mPostWordFaceBookUserName,mFacebookTitleWordString,linkString];
	UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:appDelegate._engine delegate:self];
	if (controller) {
		[self presentModalViewController:controller animated:YES];
	} 
	else {
		//[appDelegate._engine sendUpdate:postString];
		[appDelegate._engine getUserInformationFor:[appDelegate._engine username]];
	}
	
}

#pragma mark-
#pragma mark getTwitterUserName method

- (void)getTwitterUserName:(NSNotification *)notificationObject {
	self.mPostWordFaceBookUserName = (NSString *)[notificationObject object];
	//NSString *wordTitleAndMeaningString = [mFacebookTitleWordString stringByAppendingString:[NSString stringWithFormat:@"\n \n%@",mFacebookDescriptionWordString]];
	//NSString *linkString = @"http://itunes.apple.com/in/app/nigerian-grammar/id365312654?mt=8";
	NSString *linkString = @"http://www.nigeriangrammar.com/downloads";
	NSString *postString = [NSString stringWithFormat:@"%@ likes the grammar \"%@\" on the @NigerianGrammar mobile app.%@",self.mPostWordFaceBookUserName,mFacebookTitleWordString,linkString];
	[appDelegate._engine sendUpdate:postString];
	//NSLog(@"name is:%@",self.mPostWordFaceBookUserName);
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
		NSString *linkString = @"http://itunes.apple.com/in/app/nigerian-grammar/id365312654?mt=8";
		//NSString *postString = [NSString stringWithFormat:@"%@ likes the phrase/Quote/Saying %@ on the Nigerian Grammar PHONE_PLATFORM app. Be a part of the movement. Download Yours today. Nigerian Grammar mobile app available for iPad, iPhone, iPad and Android.",self.mPostWordFaceBookUserName,mFacebookTitleWordString];
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


#pragma mark-
#pragma mark FBLoginSession Delegates

/**
 * Called when the dialog successful log in the user
 
 
 */

/*
- (void)fbDidLogin{
	NSString *wordTitleAndMeaningString = [mFacebookTitleWordString stringByAppendingString:[NSString stringWithFormat:@"\n%@",mFacebookDescriptionWordString]];
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",wordTitleAndMeaningString],  @"message",nil];
	//[appDelegate.mFacebook dialog:@"feed" andParams:params andDelegate:self];
	//[appDelegate.mFacebook requestWithGraphPath:@"me" andDelegate:self];
	[appDelegate.mFacebook requestWithMethodName:@"stream.publish" andParams:params andHttpMethod:@"POST" andDelegate:self];
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

- (void)request:(FBRequest*)request didLoad:(id)result{
	if([[request url] isEqualToString:@"https://graph.facebook.com/me?fields=name,picture,id"]) {
	}
	else {
		NSLog(@"facebook userinfo is:%@",result);
		UIAlertView *dataPostAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Word & Meaning Successfully post" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
		[dataPostAlert show];
		[dataPostAlert release];
	}
}




//=============================================================================================================================
#pragma mark TwitterEngineDelegate

- (void) requestSucceeded: (NSString *) requestIdentifier {
	NSLog(@"Request %@ succeeded", requestIdentifier);
	UIAlertView *dataPostAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Word & Meaning Successfully post" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
	[dataPostAlert show];
	[dataPostAlert release];
}

- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username {
	//NSString *wordTitleAndMeaningString = [mFacebookTitleWordString stringByAppendingString:[NSString stringWithFormat:@"\n \n%@",mFacebookDescriptionWordString]];
	//[appDelegate._engine sendUpdate:@"test"];
	NSString *userInfo = [appDelegate._engine getUserInformationFor:username];
	NSLog(@"information is:%@",userInfo);
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

-(IBAction) backClicked;
{
	[self.navigationController popViewControllerAnimated:YES];
}

@end
