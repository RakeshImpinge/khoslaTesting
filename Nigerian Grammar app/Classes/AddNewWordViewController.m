//
//  AddNewWordViewController.m
//  Dictionary
//
//  Created by haramandeep on 08/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddNewWordViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NSObject+SBJSON.h"
#import "AddWord.h"
#import "NSString+SBJSON.h"
#import "SA_OAuthTwitterEngine.h"
#import "MGTwitterEngineGlobalHeader.h"
#import "MGTwitterHTTPURLConnection.h"
#include <CoreGraphics/CoreGraphics.h>

#define kOAuthConsumerKey		@"d3IGHYiiyDm99gVhNsxWEw"		// Replace these with your consumer key 
#define	kOAuthConsumerSecret	@"o41y6W9RGaC2hYxYeBUQzkUszOdJwoon1YsBU9f88"		// and consumer secret from 




@implementation AddNewWordViewController
@synthesize mEnterWordTextField;
@synthesize mMeaningTextView;
@synthesize mSubmitFacebookButton;
@synthesize mSubmitTwitterButton;
@synthesize mFBUserName;
@synthesize mWordPhraseLabel;
@synthesize mMeaningLabel;
@synthesize mAddWordImageView;
@synthesize isKeyBoardUp;
@synthesize isKeyBoardTextView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	appDelegate = (DictionaryAppDelegate*)[[UIApplication sharedApplication] delegate];
	self.mFBUserName = [[NSString alloc] init];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTwitterUserName:) name:@"TWITTERUSERNAME_WORDLIST" object:nil];
	mResponseDataDictionary = [[NSMutableDictionary alloc] init];
    self.mEnterWordTextField.delegate = self;
	self.mMeaningTextView.delegate = self;
	[[self.mMeaningTextView layer] setCornerRadius:3];
	[self.mMeaningTextView setClipsToBounds:YES];
	[[self.mMeaningTextView layer] setBorderColor:[UIColor darkGrayColor].CGColor];
	[[self.mMeaningTextView layer] setBorderWidth:2.0];
	self.mMeaningTextView.scrollsToTop = YES;
	[[self.mEnterWordTextField layer] setCornerRadius:3];
	[self.mEnterWordTextField setClipsToBounds:YES];
	[[self.mEnterWordTextField layer] setBorderColor:[UIColor darkGrayColor].CGColor];
	[[self.mEnterWordTextField layer] setBorderWidth:2.0];
	mLogoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
	mLogoImageView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:mLogoImageView];
	UIImage *logoImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Nigerian-Grammar" ofType:@"png"]];
	[mLogoImageView setImage:logoImage];
	[logoImage release];
	
}

#pragma mark-
#pragma mark viewWillAppear 

- (void)viewWillAppear:(BOOL)animated {
	appDelegate.mCurrentActiveViewController = NSStringFromClass([self class]);
	mEnterWordTextField.text = @"";
	mMeaningTextView.text = @"";
}

#pragma mark-
#pragma mark getTwitterUserName 

- (void)getTwitterUserName:(NSNotification *)notificationObject {
	self.mFBUserName = (NSString *)[notificationObject object];
	mResponseDataDictionary = [self passDataToWebService:self.mFBUserName];
	[self saveResponseDataToCoreDatabase];
	NSLog(@"dictionary are:%@",mResponseDataDictionary);
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark-
#pragma mark saveResponseData ToCoreDatabase

- (void)saveResponseDataToCoreDatabase {
	AddWord *addWordEntityObject = (AddWord *)[NSEntityDescription insertNewObjectForEntityForName:@"AddWord" inManagedObjectContext:appDelegate.managedObjectContext];
	//NSString *idValue = (NSString*)[mResponseDataDictionary valueForKey:@"id"];
	addWordEntityObject.ServerID = [NSNumber numberWithInt:[[mResponseDataDictionary valueForKey:@"id"]intValue]];
	addWordEntityObject.Word = [NSString stringWithFormat:@"%@",[mResponseDataDictionary valueForKey:@"word"]];
	addWordEntityObject.Description = [NSString stringWithFormat:@"%@",[mResponseDataDictionary valueForKey:@"description"]];
    addWordEntityObject.Status = [NSNumber numberWithInt:[[mResponseDataDictionary valueForKey:@"status"] intValue]];	
	NSError *error = nil;
	[appDelegate.managedObjectContext save:&error];
	if (error) {
		UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Data is not saved" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
		[errorAlert show];
		[errorAlert release];
	}
	else {
		NSLog(@"data saved");
	}
}

#pragma mark-
#pragma mark post Data to Server

- (NSMutableDictionary *)passDataToWebService:(NSString *)userName {
	NSMutableDictionary *resultDict = nil;
	NSString *requestUrlString = [[NSString alloc] initWithFormat:@"http://nile.impingesolutions.com/Others/admin.nigeriangrammar.com/public_html/addict_detail.php"];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[requestUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [requestUrlString release];
    //NSString *requestBody = [NSString stringWithFormat:@"word=jsdk&description=wew", [mDataSendDictionary JSONRepresentation]];
	NSLog(@"facebook name uis:%@",self.mFBUserName);
	NSString *requestBody = [NSString stringWithFormat:@"word=%@&description=%@&username=%@",mEnterWordTextField.text,mMeaningTextView.text,userName];
	
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
		[dataStr release];
		if ([responseArray count]) {
			resultDict = [responseArray objectAtIndex:0];
		}
		UIAlertView *postAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Successfully Post" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
		[postAlert show];
		[postAlert release];
	}
	self.mEnterWordTextField.text = @"";
	self.mMeaningTextView.text = @"";
	return resultDict;
}




#pragma mark-
#pragma mark submit Facebook button clicked methods

- (IBAction)submitByFaceBookButtonClicked {
	if([self.mEnterWordTextField.text isEqualToString:@""] && [self.mMeaningTextView.text isEqualToString:@""]) {
		UIAlertView *validationAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Word & Meaning can't be empty" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
		[validationAlert show];
		[validationAlert release];
	}
	else if([self.mEnterWordTextField.text isEqualToString:@""]) {
		UIAlertView *validationAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Word can't be empty" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
		[validationAlert show];
		[validationAlert release];
	}
	else if([self.mMeaningTextView.text isEqualToString:@""]) {
		UIAlertView *validationAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Meaning can't be empty" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
		[validationAlert show];
		[validationAlert release];
	}
	else {
		if (![appDelegate.mFacebook isSessionValid]) {
			[appDelegate.mFacebook authorize:@"112189338856784" permissions:[NSArray arrayWithObjects:@"offline_access", @"publish_stream", nil] delegate:self];
		}
		else {
			[self fbDidLogin];
		}
	}
		/*
		mResponseDataDictionary = [self passDataToWebService:self.mFBUserName];
		[self saveResponseDataToCoreDatabase];
		NSLog(@"dictionary are:%@",mResponseDataDictionary);
		
		//NSLog(@"id is:%@",[mResponseDataDictionary valueForKey:@"id"]);
		//NSLog(@"word is:%@",[mResponseDataDictionary valueForKey:@"word"]);
		//NSLog(@"description is:%@",[mResponseDataDictionary valueForKey:@"description"]);
		//NSLog(@"status is:%@",[mResponseDataDictionary valueForKey:@"status"]);
		//NSLog(@"facebook username  is:%@",[mResponseDataDictionary valueForKey:@"fb_username"]); 
		[self.mAddWordUIView removeFromSuperview];
	} */
	
	
	
}

#pragma mark-
#pragma mark submit Twitter button clicked methods


- (IBAction)submitByTwitterButtonClicked {
	if([self.mEnterWordTextField.text isEqualToString:@""] && [self.mMeaningTextView.text isEqualToString:@""]) {
		UIAlertView *validationAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Word & Meaning can't be empty" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
		[validationAlert show];
		[validationAlert release];
	}
	else if([self.mEnterWordTextField.text isEqualToString:@""]) {
		UIAlertView *validationAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Word can't be empty" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
		[validationAlert show];
		[validationAlert release];
	}
	else if([self.mMeaningTextView.text isEqualToString:@""]) {
		UIAlertView *validationAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Meaning can't be empty" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
		[validationAlert show];
		[validationAlert release];
	}
	else {
	UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:appDelegate._engine delegate:self];
	if (controller) {
		[self presentModalViewController:controller animated:YES];
	} 
	else {
		[appDelegate._engine getUserInformationFor:[appDelegate._engine username]];
	  }
	}
	
}

#pragma mark-
#pragma mark FBLoginSession Delegates

/**
 * Called when the dialog successful log in the user
 */
- (void)fbDidLogin{
	[appDelegate.mFacebook requestWithGraphPath:@"me" andDelegate:self];
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
	
}
- (void)request:(FBRequest*)request didLoadRawResponse:(NSData*)data {
	NSString *requestString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [requestString JSONValue];
	[requestString release];
	self.mFBUserName = [dict valueForKey:@"name"];
	mResponseDataDictionary = [self passDataToWebService:self.mFBUserName];
	[self saveResponseDataToCoreDatabase];
	NSLog(@"dictionary are:%@",mResponseDataDictionary);
	
	
}

#pragma mark-
#pragma mark SA_OAuthTwitterControllerDelegate

- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username {
	//NSString *wordTitleAndMeaningString = [mFacebookTitleWordString stringByAppendingString:[NSString stringWithFormat:@"\n \n%@",mFacebookDescriptionWordString]];
	NSString *userInfo = [appDelegate._engine getUserInformationFor:username];
		

}   

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier {
	NSLog(@"userinfo is:%@",userInfo);
	NSLog(@"twitter user name is%@", [userInfo valueForKey:@"name"]);
}

#pragma mark TwitterEngineDelegate

- (void)receivedObject:(NSDictionary *)dictionary forRequest:(NSString *)connectionIdentifier {
	NSLog(@"%@",dictionary);	
}
- (void) requestSucceeded: (NSString *) requestIdentifier {
	NSLog(@"Request %@ succeeded", requestIdentifier);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // Show error
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
    // Once this method is invoked, "responseData" contains the complete result
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




#pragma mark-
#pragma mark textView delegates

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
		[textView resignFirstResponder];
		// Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	if(!isKeyBoardUp) {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
	CGRect frame = self.view.frame;
	frame.origin.y -= 140;
	self.view.frame = frame;
	[UIView setAnimationDelegate:self];	
	[UIView commitAnimations];
		isKeyBoardUp = TRUE;
	}
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	[self performSelector:@selector(textViewEnd) withObject:nil afterDelay:.01];
}


- (void)textViewEnd {
	if(![self.mEnterWordTextField isFirstResponder]) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
		CGRect frame = self.view.frame;
		frame.origin.y += 140;
		self.view.frame = frame;
		[UIView setAnimationDelegate:self];	
		[UIView commitAnimations];
		isKeyBoardUp = FALSE;
	}
	
}


#pragma mark-
#pragma mark textField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;	
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
	if(!isKeyBoardUp) {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
	CGRect frame = self.view.frame;
	frame.origin.y -= 140;
	self.view.frame = frame;
	[UIView setAnimationDelegate:self];	
	[UIView commitAnimations];
	self.isKeyBoardUp = TRUE;
	}
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
	[self performSelector:@selector(textFieldEnd) withObject:nil afterDelay:.01];
}

- (void)textFieldEnd {
	if(![self.mMeaningTextView isFirstResponder]) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
		CGRect frame = self.view.frame;
		frame.origin.y += 140;
		self.view.frame = frame;
		[UIView setAnimationDelegate:self];	
		[UIView commitAnimations];
		isKeyBoardUp = FALSE;
	}
}


#pragma mark-
#pragma mark memory management methods


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
	self.mEnterWordTextField = nil;
	self.mMeaningTextView = nil;
	self.mSubmitFacebookButton = nil;
	self.mSubmitTwitterButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[mEnterWordTextField release];
	[mMeaningTextView release];
	[mSubmitFacebookButton release];
	[mSubmitTwitterButton release];
	[mFBUserName release];
	[mResponseDataDictionary release];
	[mLogoImageView release];
	[mWordPhraseLabel release];
	[mMeaningLabel release];
	[mAddWordImageView release];
    [super dealloc];
}


@end
