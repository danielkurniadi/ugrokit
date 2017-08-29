//
//  downloadInv.m
//  ApiDemo
//
//  Created by Student 3 on 14/5/17.
//  Copyright © 2017 U Grok It. All rights reserved.
//

#import "downloadInv.h"
#import "Constants.h"
#import "itemList.h"

@interface downloadInv ()

@end

@implementation downloadInv
    


- (void)viewDidLoad {
    [super viewDidLoad];
    //inv_list = [[NSMutableArray alloc] init];
    [self fetchInvList];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//fetch list of database
-(void) fetchInvList{
    NSError *error;
    NSString *url_string = [NSString stringWithFormat: @"%@inventory.php?method=GET_INV", URL_HEADER];
    NSLog(@"%@",url_string);
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    
    
    NSString *response = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    
    //NSLog(@"%@",[response substringWithRange:NSMakeRange(1, 1)]);
    
    NSLog(@"%@", response);
    
    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"%@",url_string);
    //NSLog(@"%@",json);
    
    self.inv_list = [json valueForKeyPath:@"inv_name"];
    
    NSLog(@"%@", self.inv_list);
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.inv_list count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
 static NSString *simpleTableIdentifier = @"inv_cell";
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
 
 if(cell==nil){
 cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
 }
 
 cell.textLabel.text = [self.inv_list objectAtIndex:indexPath.row];

 cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
 return cell;
 
}
//what happens if one of the row is selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    [self performSegueWithIdentifier:@"itemListSegue" sender:self];
    
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

    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"itemListSegue"])
    {
        itemList *vc = (itemList *)[segue destinationViewController];
        [vc setInv:[self.inv_list objectAtIndex:indexPath.row]];
        vc.title = vc.inv;
    }
}


- (void)dealloc {
    [_table_view release];
    [_table_view release];
    [super dealloc];
}
@end
