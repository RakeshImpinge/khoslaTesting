//
//  AboutView.m
//  Dictionary
//
//  Created by Kanchan on 08/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AboutView.h"
#import "XPathQuery.h"

@implementation AboutView

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

	[self.view addSubview:spinnerView];
	[spinner startAnimating];
	
	[self performSelector:@selector(start) withObject:nil afterDelay:0.1];
	
	
}

- (void) start{

	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.admin.nigeriangrammar.com/fetch_content.php"]];
	
	NSURLResponse *response;
	NSError *error;
	NSData *responseData;
	
	responseData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
	
	NSArray *result = [[NSArray alloc] initWithArray:PerformXMLXPathQuery(responseData, @"//content" )];
	
	NSString *dataString;
	if([result count])
		dataString = [[result objectAtIndex:0] valueForKey:@"nodeContent"]; 
	else
		dataString = @"Nigerian Grammar is the tool that everyone has been waiting for. Because it functions as a dictionary for Nigerian Pidgin—words, slang and phrases— this easy to use app allows you to search and learn.  Now you will know what the words and phrases you hear in Nigerian movies and from your mates mean. Be a part of this movement; log on to www.nigeriangrammar.com and submit your favorite grammar.  When we update the app, you will be credited for your submissions and in turn help in growing this valuable resource. \n  Join the movement. \nBe a fan on Facebook:  http://www.facebook.com/nigeriangrammar  \nFollow us on Twitter: www.twitter.com/nigeriangrammar";
	
	mAboutUsView.text = dataString;
	
	[result release];
	[spinner stopAnimating];
	[spinnerView removeFromSuperview];
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
}


- (void)dealloc {
    [super dealloc];
}
-(void) refreshDone{
	mUpdateButton.enabled = NO;
	appDelegate = (DictionaryAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSFetchRequest * request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"WordList" inManagedObjectContext:appDelegate.managedObjectContext];
	[request setEntity: entity];
	NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:request error:nil];
	[request release];
	for(int i= 0; i< [results count]; i++)
	{
		[appDelegate.managedObjectContext deleteObject:[results objectAtIndex:i]];
		
	}
	results = nil;
	
	NSFetchRequest * request1 = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity1 = [NSEntityDescription entityForName:@"Description" inManagedObjectContext:appDelegate.managedObjectContext];
	[request1 setEntity: entity1];
	NSArray *results1 = [appDelegate.managedObjectContext executeFetchRequest:request1 error:nil];
	[request1 release];
	for(int i= 0; i< [results1 count]; i++)
	{
		[appDelegate.managedObjectContext deleteObject:[results1 objectAtIndex:i]];
		
	}
	results1 = nil;

	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.admin.nigeriangrammar.com/fetch_xml.php"]];

	[appDelegate performSelectorOnMainThread:@selector(getWordsFor:) withObject:urlRequest waitUntilDone:YES];
	//[self createDifferentArray];
	[mUpdateButton setEnabled:YES];
	[spinner stopAnimating];
	[spinnerView removeFromSuperview];
	//[spinner release];
	mUpdateButton.enabled = YES;
	//[mWordsTableView reloadData];
	
}
-(IBAction) updateClicked
{
	[mUpdateButton setEnabled:NO];
	hostReach = [[Reachability reachabilityForInternetConnection] retain];
	[hostReach startNotifer];
	[self updateInterfaceWithReachability: hostReach];
	
}

- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
	
	if(netStatus == NotReachable){
		UIAlertView *connectionAlert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Please connect to a wifi or cellular network to update the Dictionary" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[connectionAlert show];
		[connectionAlert release];
		[mUpdateButton setEnabled:YES];
	}
	else {
		[self doneUpdate];
	}
}	
-(void) doneUpdate
{
    //spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	//spinner.frame = CGRectMake(135, 195, 50, 50);
	[self.view addSubview:spinnerView];
	[spinner startAnimating];
	//[self.view addSubview:spinner];
	[self performSelector:@selector(refreshDone) withObject:nil afterDelay:0.1];
	
	
}

@end
