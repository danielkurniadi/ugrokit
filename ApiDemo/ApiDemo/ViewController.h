//
//  ViewController.h
//  ApiDemo
//
//  Created by Tony Requist on 3/9/16.
//  Copyright © 2016 U Grok It. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UgiInventoryDelegate.h"
#import "UgiViewController.h"

@interface ViewController : UgiViewController<UITableViewDelegate, UITableViewDataSource, UgiInventoryDelegate>


@end

