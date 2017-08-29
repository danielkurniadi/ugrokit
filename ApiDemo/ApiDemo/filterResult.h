//
//  filterResult.h
//  ApiDemo
//
//  Created by Student 3 on 28/5/17.
//  Copyright © 2017 U Grok It. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface filterResult : UITableViewController

@property(nonatomic, strong) NSMutableArray *items;
@property(nonatomic, strong) NSMutableArray *dataArray;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *exportBtn;
- (IBAction)exportAct:(id)sender;

@end
