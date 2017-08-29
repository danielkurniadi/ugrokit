//
//  downloadInv.h
//  ApiDemo
//
//  Created by Student 3 on 14/5/17.
//  Copyright © 2017 U Grok It. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface downloadInv : UITableViewController
@property (retain, nonatomic) IBOutlet UITableView *table_view;
@property (nonatomic, strong) NSMutableArray *inv_list;
@end
