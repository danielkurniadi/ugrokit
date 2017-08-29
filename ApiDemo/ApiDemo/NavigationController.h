//
//  NavigationController.h
//  UGrokIt
//
//  Created by Anthony Requist on 1/22/13.
//  Copyright (c) 2013 Anthony Requist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UgiUiUtil.h"

//
// We need to subclass UINavigationController to handle screen rotation on
// the iPhone 4 and 4S, which have the audio port on the top of the phone.
// If you are not concerned with iPhone 4 support, you don't need this.
//
@interface NavigationController : UINavigationController

///////////////////////////////////////////////////////////////////////////////////////


#pragma mark - Methods
///////////////////////////////////////////////////////////////////////////////////////

@end
