//
//  AboutView.h
//  Dictionary
//
//  Created by Kanchan on 08/03/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DictionaryAppDelegate.h"
#import "Reachability.h"



@interface AboutView : UIViewController {
	 IBOutlet UITextView *mAboutUsView;
	IBOutlet UIButton *mUpdateButton;
	DictionaryAppDelegate *appDelegate;
	IBOutlet UIActivityIndicatorView *spinner;
	Reachability* hostReach;
	IBOutlet UIView *spinnerView;

}

-(IBAction) updateClicked;
- (void) updateInterfaceWithReachability: (Reachability*) curReach;
-(void) doneUpdate;

@end
