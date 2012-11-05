//
//  Description.h
//  Dictionary
//
//  Created by Gursharan Somal on 26/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class WordList;

@interface Description :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * mId;
@property (nonatomic, retain) WordList * linkedTo;

@end



