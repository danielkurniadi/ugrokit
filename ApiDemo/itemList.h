//
//  itemList.h
//  ApiDemo
//
//  Created by Student 3 on 16/5/17.
//  Copyright © 2017 U Grok It. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface itemList : UITableViewController

@property(nonatomic, strong) NSString *inv;

@property (retain, nonatomic) IBOutlet UIBarButtonItem *filterBtn;

- (IBAction)filterAct:(id)sender;

@end
