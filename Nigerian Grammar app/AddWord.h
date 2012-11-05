//
//  AddWord.h
//  Dictionary
//
//  Created  on 18/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface AddWord :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * ServerID;
@property (nonatomic, retain) NSString * Description;
@property (nonatomic, retain) NSNumber * Status;
@property (nonatomic, retain) NSString * Word;

@end



