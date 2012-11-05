//
//  WordsListView.m
//  Dictionary
//
//  Created by haramandeep on 25/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WordsListView.h"
#import "WordList.h"
#import "Description.h"
#import "DetailView.h"
#include <QuartzCore/QuartzCore.h>
#import "NSObject+SBJSON.h"
#import "AddWord.h"
#import "NSString+SBJSON.h"

#include <QuartzCore/QuartzCore.h>
#include <CoreGraphics/CoreGraphics.h>




@implementation WordsListView
@synthesize mWordsTableView;
@synthesize mHeaderArray;
@synthesize descArray;
//@synthesize header;
//@synthesize rowCount;
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
	{
        // Custom initialization
		self.title =@"Words Lists";
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	mWordsTableView.backgroundColor = [UIColor clearColor];
	mWordsTableView.separatorColor = [UIColor lightGrayColor];
	descArray = [[NSMutableArray alloc]init];
	mHeaderArray = [[NSMutableArray alloc]initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"z",nil];

	
}

-(void)viewWillAppear: (BOOL)animated{
	[self createDifferentArray];
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
	
	
}

- (void)viewDidUnload {
	self.mWordsTableView = nil;
}


- (void)dealloc {
	[mWordsTableView release];
	[mWordsArray release];
	[mHeaderArray release];
	[descArray release];
	[descArray release];
	[allAlphabetArray release];
	allAlphabetArray = nil;
	//[mBackButton release];
	//[mWordListImageView release];
	//[rowCount release];
	//[header release];
	
    [super dealloc];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	
	return [mHeaderArray count];	
		
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[allAlphabetArray objectAtIndex:section] count];
		
		
	
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
	return 38.0;	
		
		
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
	}
	
	NSArray *views = [cell.contentView subviews];
	for( int i = 0; i < [views count]; i++) 
	{
		UIView *tempView = [views objectAtIndex:i];
		[tempView removeFromSuperview];
		tempView = nil;
	}
	views = nil;
	
	cell.textLabel.textColor = [UIColor blackColor];
	if(indexPath.row==0)
	{
		cell.textLabel.text= [mHeaderArray objectAtIndex:indexPath.section];
		cell.textLabel.textColor = [UIColor colorWithRed:0.0 green:.57 blue:.33 alpha:1.0];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:22];
	}
	else{
		
		cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
		cell.textLabel.text = [[[[allAlphabetArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row-1] valueForKey:@"title"] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	}
    return cell;
	
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
		
	rowCount = indexPath.row;
	[descArray removeAllObjects];
	NSArray *tempArray = [[[[allAlphabetArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row-1] valueForKey:@"des"] allObjects];

	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"mId" ascending:true];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	tempArray = [tempArray sortedArrayUsingDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];
	
	for (int i=0; i<[tempArray count] ; i++) {
		[descArray addObject:[[tempArray objectAtIndex:i]desc]];
	}
	
	header = [[[allAlphabetArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row-1] valueForKey:@"title"];
	DetailView *detailView = [[ DetailView alloc] initWithNibName:@"DetailView" bundle:[NSBundle mainBundle]];
	
	detailView.mDescArray = descArray;
	detailView.mHeader = header;
	[self.navigationController pushViewController:detailView animated:YES];
	[detailView release];
	
}



-(void)createDifferentArray
{
	if(mWordsArray){
		[mWordsArray release];
		mWordsArray = nil;
	}
		
	mWordsArray = [[NSArray alloc]initWithArray:[self fetchAllRecordsFromDatabase]];
	mAArray = [[NSMutableArray alloc]init];
	mBArray = [[NSMutableArray alloc]init];
	mCArray = [[NSMutableArray alloc]init];
	mDArray = [[NSMutableArray alloc]init];
	mEArray = [[NSMutableArray alloc]init];
	mFArray = [[NSMutableArray alloc]init];
	mGArray = [[NSMutableArray alloc]init];
	mHArray = [[NSMutableArray alloc]init];
	mIArray = [[NSMutableArray alloc]init];
	mJArray = [[NSMutableArray alloc]init];
	mKArray = [[NSMutableArray alloc]init];
	mLArray = [[NSMutableArray alloc]init];
	mMArray = [[NSMutableArray alloc]init];
	mNArray = [[NSMutableArray alloc]init];
	mOArray = [[NSMutableArray alloc]init];
	mPArray = [[NSMutableArray alloc]init];
	mQArray = [[NSMutableArray alloc]init];
	mRArray = [[NSMutableArray alloc]init];
	mSArray = [[NSMutableArray alloc]init];
	mTArray = [[NSMutableArray alloc]init];
	mUArray = [[NSMutableArray alloc]init];
	mVArray = [[NSMutableArray alloc]init];
	mWArray = [[NSMutableArray alloc]init];
	mXArray = [[NSMutableArray alloc]init];
	mYArray = [[NSMutableArray alloc]init];
	mZArray = [[NSMutableArray alloc]init];

	for(int i=0;i<[mWordsArray count];i++)
	{
		NSDictionary *dict = [mWordsArray objectAtIndex:i];
		NSString *orignalString = [dict valueForKey:@"title"];
		
		NSString *tempString = [orignalString substringToIndex:1];
			
		if([tempString isEqualToString:@"a"]||[tempString isEqualToString:@"A"]){
			[mAArray addObject:dict];
				
		}
		else if([tempString isEqualToString:@"b"]||[tempString isEqualToString:@"B"]){
			[mBArray addObject:dict];
		}
		
		      else if([tempString isEqualToString:@"c"]||[tempString isEqualToString:@"C"])
		       {
			    [mCArray addObject:dict];
			   }
		        else if([tempString isEqualToString: @"d"]||[tempString isEqualToString:@"D"])
		         {
			      [mDArray addObject:dict];
			     }
				 else if([tempString isEqualToString: @"e"]||[tempString isEqualToString:@"E"])
			      {
				   [mEArray addObject:dict];
			      }
				   else if([tempString isEqualToString: @"f"]||[tempString isEqualToString:@"F"])
				    {
					 [mFArray addObject:dict];
				    }
				   else if([tempString isEqualToString: @"g"]||[tempString isEqualToString:@"G"])
				   {
					   [mGArray addObject:dict];
				   }else if([tempString isEqualToString: @"h"]||[tempString isEqualToString:@"H"])
				   {
					   [mHArray addObject:dict];
				   }else if([tempString isEqualToString: @"i"]||[tempString isEqualToString:@"I"])
				   {
					   [mIArray addObject:dict];
				   }else if([tempString isEqualToString: @"j"]||[tempString isEqualToString:@"J"])
				   {
					   [mJArray addObject:dict];
				   }else if([tempString isEqualToString: @"k"]||[tempString isEqualToString:@"K"])
				   {
					   [mKArray addObject:dict];
				   }else if([tempString isEqualToString: @"l"]||[tempString isEqualToString:@"L"])
				   {
					   [mLArray addObject:dict];
				   }else if([tempString isEqualToString: @"m"]||[tempString isEqualToString:@"M"])
				   {
					   [mMArray addObject:dict];
				   }else if([tempString isEqualToString: @"n"]||[tempString isEqualToString:@"N"])
				   {
					   [mNArray addObject:dict];
				   }else if([tempString isEqualToString: @"o"]||[tempString isEqualToString:@"O"])
				   {
					   [mOArray addObject:dict];
				   }else if([tempString isEqualToString: @"p"]||[tempString isEqualToString:@"P"])
				   {
					   [mPArray addObject:dict];
				   }else if([tempString isEqualToString: @"q"]||[tempString isEqualToString:@"Q"])
				   {
					   [mQArray addObject:dict];
				   }else if([tempString isEqualToString: @"r"]||[tempString isEqualToString:@"R"])
				   {
					   [mRArray addObject:dict];
				   }else if([tempString isEqualToString: @"s"]||[tempString isEqualToString:@"S"])
				   {
					   [mSArray addObject:dict];
				   }else if([tempString isEqualToString: @"t"]||[tempString isEqualToString:@"T"])
				   {
					   [mTArray addObject:dict];
				   }else if([tempString isEqualToString: @"u"]||[tempString isEqualToString:@"U"])
				   {
					   [mUArray addObject:dict];
				   }else if([tempString isEqualToString: @"v"]||[tempString isEqualToString:@"V"])
				   {
					   [mVArray addObject:dict];
				   }else if([tempString isEqualToString: @"w"]||[tempString isEqualToString:@"W"])
				   {
					   [mWArray addObject:dict];
				   }else if([tempString isEqualToString: @"x"]||[tempString isEqualToString:@"X"])
				   {
					   [mXArray addObject:dict];
				   }else if([tempString isEqualToString: @"y"]||[tempString isEqualToString:@"Y"])
				   {
					   [mYArray addObject:dict];
				   }else if([tempString isEqualToString: @"z"]||[tempString isEqualToString:@"Z"])
				   {
					   [mZArray addObject:dict];
				   }
		

	}
	allAlphabetArray = [[NSMutableArray alloc] initWithObjects:mAArray, mBArray, mCArray, mDArray, mEArray, mFArray,
	mGArray, mHArray, mIArray, mJArray, mKArray, mLArray, mMArray, mNArray, mOArray, mPArray, mQArray, mRArray, mSArray, 
						mTArray, mUArray, mVArray, mWArray, mXArray, mYArray, mZArray, nil];
	[mAArray release];
	[mBArray release];
	[mCArray release];
	[mDArray release];
	[mEArray release];
	[mFArray release];
	[mGArray release];
	[mHArray release];
	[mIArray release];
	[mJArray release];
	[mKArray release];
	[mLArray release];
	[mMArray release];
	[mNArray release];
	[mOArray release];
	[mPArray release];
	[mQArray release];
	[mRArray release];
	[mSArray release];
	[mTArray release];
	[mUArray release];
	[mVArray release];
	[mWArray release];
	[mXArray release];
	[mYArray release];
	[mZArray release];
	
	[mWordsTableView reloadData];
	
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

@end
