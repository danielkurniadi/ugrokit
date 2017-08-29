//
//  itemList.m
//  ApiDemo
//
//  Created by Student 3 on 16/5/17.
//  Copyright © 2017 U Grok It. All rights reserved.
//

#import "itemList.h"
#import "Constants.h"
#import "Ugi.h"
#import "UgiFooterView.h"
#import "filterPage.h"


@interface itemList ()

@property (retain, nonatomic) IBOutlet UgiFooterView *footer;

@end

@implementation itemList{
    NSArray *item_list;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateUI];
    [self fetchItemList];
    

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) updateUI{
    [self.footer setCenterText:NSLocalizedStringWithDefaultValue(@"FooterStart", @"Localizable", [NSBundle mainBundle], @"start", @"Footer button: export csv") withCompletion:^{
        //[self startScanning];
        NSLog(@"button pressed");
    }];
}

-(void) fetchItemList{
    NSString *invID = [self inv];
    NSError *error;
    NSString *url_string = [NSString stringWithFormat: @"%@inventory.php?method=GET_ITEM&inv=%@", URL_HEADER, invID];
    NSLog(@"%@",url_string);
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    
    
    NSString *response = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    
    //NSLog(@"%@",[response substringWithRange:NSMakeRange(1, 1)]);
    
    NSLog(@"%@", response);
    
    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"%@",url_string);
    //NSLog(@"%@",json);
    
    item_list = [json valueForKeyPath:@"item"];
    
    NSLog(@"%@", item_list);
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [item_list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"itemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if(cell==nil){
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [item_list objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"filterSegue"])
    {
        filterPage *vc = (filterPage *)[segue destinationViewController];
        [vc setInv:_inv];
        vc.title = vc.inv;
    }
}


- (void)dealloc {
    [_filterBtn release];
    [super dealloc];
}
- (IBAction)filterAct:(id)sender {
    [UgiUiUtil
     showMenuWithTitle:@"choose action"
     withCancelCompletion:nil
     withItems:[NSArray arrayWithObjects:
                [UgiMenuItem itemWithTitle:@"Filter"
                               withHandler:^{
                                   [self performSegueWithIdentifier:@"filterSegue" sender:self];
                               }],
                [UgiMenuItem itemWithTitle:@"Export CSV"
                               withHandler:^{
                                   [self performSegueWithIdentifier:@"downloadInvSegue" sender:self];
                               }],
                nil]];
}
@end
