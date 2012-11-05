//
//  WordOfDayView.m
//  Dictionary
//
//  Created by haramandeep on 25/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WordOfDayView.h"
#import "Description.h"

@implementation WordOfDayView
@synthesize mTableView;
//@synthesize mNameLabel;
//@synthesize mDescriptionLabel;
//@synthesize mWordsArray;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
	{
        // Custom initialization
		self.title = @"Today's Grammar";
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	mDescArray = [[NSMutableArray alloc]init];

	[self generateWordOfTheDay];
	mTableView.backgroundColor =[UIColor clearColor]; 
	mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}
-(void)viewWillAppear: (BOOL)animated{
	
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
	
	[mHeader release];
	[mWordsArray release];
	[mDescArray release];
	[mTableView release];
    [super dealloc];
}
-(void)generateWordOfTheDay
{
	mWordsArray = [[NSArray alloc]initWithArray:[self fetchAllRecordsFromDatabase]];
	int wCount = [mWordsArray count];
	if(wCount !=0){
		int index = arc4random() % wCount; 
		[mDescArray removeAllObjects];
		NSArray *tempArray = [[[mWordsArray objectAtIndex:index]valueForKey:@"des"] allObjects];
		
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"mId" ascending:true];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		tempArray = [tempArray sortedArrayUsingDescriptors:sortDescriptors];
		[sortDescriptor release];
		[sortDescriptors release];
		
		for (int i=0; i<[tempArray count] ; i++) {
			[mDescArray addObject:[[tempArray objectAtIndex:i] desc]];
		}
		mHeader = [[NSMutableString alloc]initWithString:[[mWordsArray objectAtIndex:index]valueForKey:@"title"]];
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
		temp=temp/24;
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
	}
	else
	{
		cell.textLabel.text = [[mDescArray objectAtIndex:indexPath.row-3] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
		cell.textLabel.numberOfLines = 8;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.font = [UIFont systemFontOfSize:16];
	}
	return cell;	
	
}

@end
