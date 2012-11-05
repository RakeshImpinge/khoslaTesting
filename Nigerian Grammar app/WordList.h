//
//  WordList.h
//  Dictionary
//
//  Created  on 05/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Description;

@interface WordList :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet* des;

@end


@interface WordList (CoreDataGeneratedAccessors)
- (void)addDesObject:(Description *)value;
- (void)removeDesObject:(Description *)value;
- (void)addDes:(NSSet *)value;
- (void)removeDes:(NSSet *)value;

@end

