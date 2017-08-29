//
//  sendFile.m
//  ApiDemo
//
//  Created by Student 3 on 10/7/17.
//  Copyright © 2017 U Grok It. All rights reserved.
//

#import "sendFile.h"
#import "Constants.h"

@interface sendFile ()

@end

@implementation sendFile

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"This is sendFile %@", _dataArray);
    
    pickerDataSender = [[NSArray alloc] initWithArray:[self fetchUser]];
    pickerDataRecipient = [[NSArray alloc] initWithArray:pickerDataSender copyItems:YES];
    
    UIPickerView *pickerSender = [[UIPickerView alloc] init];
    pickerSender.dataSource = self;
    pickerSender.delegate = self;
    [pickerSender setShowsSelectionIndicator:YES];
    [self.senderTF setInputView:pickerSender];
    
    UIPickerView *pickerRecipient = [[UIPickerView alloc] init];
    pickerRecipient.dataSource = self;
    pickerRecipient.delegate = self;
    [pickerRecipient setShowsSelectionIndicator:YES];
    [self.recipientTF setInputView:pickerRecipient];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard
{
    if([_senderTF isFirstResponder]){
        [_senderTF resignFirstResponder];
    } else if ([_recipientTF isFirstResponder]){
        [_recipientTF resignFirstResponder];
    } 
    
}

- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(_senderTF.isFirstResponder){
        return [pickerDataSender count];
    }
    else{
        return [pickerDataRecipient count];
    }
    
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(_senderTF.isFirstResponder){
        return [pickerDataSender objectAtIndex:row];
    } else {
        return [pickerDataRecipient objectAtIndex:row];
    }
    
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(_senderTF.isFirstResponder){
        self.senderTF.text = [pickerDataSender objectAtIndex:row];
        [self.senderTF endEditing:YES];
    } else {
        self.recipientTF.text = [pickerDataRecipient objectAtIndex:row];
        [self.recipientTF endEditing:YES];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(NSArray *)fetchUser{
    NSArray *users;
    NSError *error;
    NSString *url_string = [NSString stringWithFormat: @"%@inventory.php?method=GET_USER", URL_HEADER];
    NSLog(@"%@",url_string);
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    
    
    NSString *response = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    
    //NSLog(@"%@",[response substringWithRange:NSMakeRange(1, 1)]);
    
    NSLog(@"%@", response);
    
    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"%@",url_string);
    //NSLog(@"%@",json);
    
    users = [json valueForKeyPath:@"username"];
    
    NSLog(@"%@", users);
    
    return users;
}
//generate file path to save csv file to
-(NSString *)dataFilePath: (NSString *) name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *file = [NSString stringWithFormat:@"%@.csv", name];
    NSLog(@"%@", file);
    return [documentsDirectory stringByAppendingPathComponent:file];
}

//read csv file and print to console
-(NSString *)readStringFromFile: (NSString *) filename{
    NSString *fileAtPath = [self dataFilePath:filename];
    //NSString *fileAtPath = [filePath stringByAppendingString:filename];
    return [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:fileAtPath] encoding:NSUTF8StringEncoding];
}

//convert dictionary to csv
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
//call php to send file
//still not working
-(BOOL)sendFile:(NSString *) filePath{
    NSArray *result;
    NSError *error;
    NSString *url_string = [NSString stringWithFormat: @"%@inventory.php?method=SEND_FILE&filepath=%@", URL_HEADER, filePath];
    NSLog(@"%@",url_string);
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    
    
    NSString *response = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    
    //NSLog(@"%@",[response substringWithRange:NSMakeRange(1, 1)]);
    
    NSLog(@"%@", response);
    
    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"%@",url_string);
    //NSLog(@"%@",json);
    
    result = [json valueForKeyPath:@"success"];
    
    NSLog(@"%@", result);
    
    if([[result objectAtIndex:0] isEqualToString: @"yes"]){
        return 1;
    } else {
        return 0;
    }
    
}

- (void)dealloc {
    [_fileNameTF release];
    [_senderTF release];
    [_recipientTF release];
    [_messageTF release];
    [_sendBtn release];
    [super dealloc];
}
- (IBAction)sendAct:(id)sender {
    [self saveCSV:_fileNameTF.text];
    NSLog(@"Saved successfully");
    [self sendFile: [self dataFilePath: _fileNameTF.text]];
}
@end
