//
//  filterResult.m
//  ApiDemo
//
//  Created by Student 3 on 28/5/17.
//  Copyright © 2017 U Grok It. All rights reserved.
//

#import "filterResult.h"
#import "UgiFooterView.h"
#import "sendFile.h"

@interface filterResult (){
    UITextField *fileTextField;
}

@end

@implementation filterResult

- (void)viewDidLoad {
    [super viewDidLoad];
    //NSLog(@"item: %@", _items);
    //NSLog(@"data: %@", _dataArray);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"resultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if(cell==nil){
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [_items objectAtIndex:indexPath.row];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
   // NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"sendEmailSegue"])
    {
        sendFile *vc = (sendFile *)[segue destinationViewController];
        [vc setDataArray:_dataArray];
    }
}
/*
-(NSString *)dataFilePath: (NSString *) name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *file = [NSString stringWithFormat:@"%@.csv", name];
    NSLog(@"%@", file);
    return [documentsDirectory stringByAppendingPathComponent:file];
}

-(NSString *)readStringFromFile: (NSString *) filename{
    NSString *fileAtPath = [self dataFilePath:filename];
    //NSString *fileAtPath = [filePath stringByAppendingString:filename];
    return [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:fileAtPath] encoding:NSUTF8StringEncoding];
}

-(void)saveCSV: (NSString *) filename{
    NSError **error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath:filename]]) {
        [[NSFileManager defaultManager] createFileAtPath: [self dataFilePath:filename] contents:nil attributes:nil];
        NSLog(@"Route created");
    }
    
    NSMutableString *writeString = [NSMutableString stringWithCapacity:0]; //don't worry about the capacity, it will expand as necessary
    
    [writeString appendString:[NSString stringWithFormat:@"item, itemID, part, category, tag, inspection_date, epc, last_scanned, \n"]];
    
    for (int i=0; i<[_dataArray count]; i++) {
        NSDictionary *dict = [_dataArray objectAtIndex:i];
        [writeString appendString:[NSString stringWithFormat:@"\"%@\", %@, %@, %@, %@, %@, %@, %@, \n",[dict objectForKey:@"item"],[dict objectForKey:@"itemID"],[dict objectForKey:@"part"],[dict objectForKey:@"category"],[dict objectForKey:@"tag"], [dict objectForKey:@"inspection_date"], [dict objectForKey:@"epc"], [dict objectForKey:@"last_scanned"]]]; //the \n will put a newline in
    }
    
    NSLog(@"writeString :\n%@",writeString);
    
    
    BOOL result = [writeString writeToFile:[self dataFilePath:filename] atomically:YES encoding:NSUTF8StringEncoding error: error];
    if(result){
        NSLog(@"Yes");
        NSString *fromFile = [self readStringFromFile:filename];
        NSLog(@"from file: %@", fromFile);
    } else {
        NSLog(@"No");
    }
}

*/
- (void)dealloc {
    [_exportBtn release];
    [super dealloc];
}
- (IBAction)exportAct:(id)sender {
    [UgiUiUtil
     showMenuWithTitle:@"choose action"
     withCancelCompletion:nil
     withItems:[NSArray arrayWithObjects:
                [UgiMenuItem itemWithTitle:@"Send via Email"
                               withHandler:^{
                                   [self sendViaEmail];
                               }],
                [UgiMenuItem itemWithTitle:@"Open via Ms Excel"
                               withHandler:^{
                                   //[self openExcel:filepath];
                               }],
                nil]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1){
        if(buttonIndex == 0){
            NSLog(@"No");
        } else {
            [self performSegueWithIdentifier:@"sendEmailSegue" sender:self];
        }
    }
    else if(alertView.tag==2){
        if(buttonIndex==0){
            NSLog(@"OK");
        } else {
            NSLog(@"lah?");
        }
    }
}

-(void)sendViaEmail{
    
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Export CSV" message:@"Send Email?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
     alert.tag = 1;
     [alert show];
    
}

-(void)openExcel: (NSString *)filepath{
    //NSString *file = @"http://www.sample-videos.com/csv/Sample-Spreadsheet-10-rows.csv";
    //NSString *excelURL = [NSString stringWithFormat:@"ms-excel:ofv|u|%@", file];
    NSString *excelURL = @"comgooglemapsurl://";
    BOOL canOpenURL = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:excelURL]];
    
    if(canOpenURL){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:excelURL]];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Microsoft Excel installed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 2;
        [alert show];
    }
}
@end
