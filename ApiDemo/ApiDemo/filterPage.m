//
//  filterPage.m
//  ApiDemo
//
//  Created by Student 3 on 28/5/17.
//  Copyright © 2017 U Grok It. All rights reserved.
//

#import "filterPage.h"
#import "Constants.h"
#import "filterResult.h"

@interface filterPage (){
    NSMutableArray *filterItems;
    NSMutableArray *filteredData;
}

@end

@implementation filterPage

- (void)viewDidLoad {
    [super viewDidLoad];
    //[scroller setScrollEnabled:YES];
    //[scroller setContentSize:CGSizeMake(320,700 )];
    
    filterItems = [[NSMutableArray alloc] init];
    filteredData = [[NSMutableArray alloc] init];
    
    pickerDataTag = [[NSArray alloc] initWithArray:[self fetchTag]];
    pickerDataCategory2 = [[NSArray alloc] initWithArray:[self fetchCat]];
    
    //category picker
    UIPickerView *pickerCat = [[UIPickerView alloc] init];
    pickerCat.dataSource = self;
    pickerCat.delegate = self;
    [pickerCat setShowsSelectionIndicator:YES];
    [self.catTextField setInputView:pickerCat];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];
    
    //tag picker
    UIPickerView *pickerTag = [[UIPickerView alloc] init];
    pickerTag.dataSource = self;
    pickerTag.delegate = self;
    [pickerTag setShowsSelectionIndicator:YES];
    [self.tagTextField setInputView:pickerTag];
    
    //inspection start date
    datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [_dateTextField setInputView:datePicker];
    
    UIToolbar *toolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [toolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *doneBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(ShowSelectedDate)];
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems:[NSArray arrayWithObjects:space,doneBtn, nil]];
    
    [_dateTextField setInputAccessoryView:toolBar];
    
    //inspection end date
    endDatePicker = [[UIDatePicker alloc] init];
    endDatePicker.datePickerMode = UIDatePickerModeDate;
    [_endDateTextField setInputView:endDatePicker];
    
    UIToolbar *toolBar2=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [toolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *doneBtn2=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(ShowSelectedDate)];
    UIBarButtonItem *space2=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar2 setItems:[NSArray arrayWithObjects:space2,doneBtn2, nil]];
    
    [_endDateTextField setInputAccessoryView:toolBar2];
    
    //last scanned start date
    lastScannedPicker = [[UIDatePicker alloc] init];
    lastScannedPicker.datePickerMode = UIDatePickerModeDate;
    [_scanTextField setInputView:lastScannedPicker];
    
    UIToolbar *scan=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [toolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *done=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(ShowSelectedDate)];
    UIBarButtonItem *space1=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [scan setItems:[NSArray arrayWithObjects:space1,done, nil]];
    
    [_scanTextField setInputAccessoryView:scan];
    
    //last scanned end date
    endLastScannedPicker = [[UIDatePicker alloc] init];
    endLastScannedPicker.datePickerMode = UIDatePickerModeDate;
    [_endScanTextField setInputView:endLastScannedPicker];
    
    UIToolbar *toolBar3=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [toolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *doneBtn3=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(ShowSelectedDate)];
    UIBarButtonItem *space3=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar3 setItems:[NSArray arrayWithObjects:space3,doneBtn3, nil]];
    
    [_endScanTextField setInputAccessoryView:toolBar3];
    

    
}
-(void)dismissKeyboard
{
    if([_itemTextField isFirstResponder]){
        [_itemTextField resignFirstResponder];
    } else if ([_partNumberTextField isFirstResponder]){
        [_partNumberTextField resignFirstResponder];
    } else if([_catTextField isFirstResponder]){
        [_catTextField resignFirstResponder];
    } else if([_tagTextField isFirstResponder]){
        [_tagTextField resignFirstResponder];
    } else if ([_dateTextField isFirstResponder]){
        [_dateTextField resignFirstResponder];
    } else if([_scanTextField isFirstResponder]){
        [_scanTextField resignFirstResponder];
    } else if([_endDateTextField isFirstResponder]){
        [_endDateTextField resignFirstResponder];
    } else if([_endScanTextField isFirstResponder]){
        [_endScanTextField resignFirstResponder];
    }
    
}


-(void)ShowSelectedDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy"];
    if([_dateTextField isFirstResponder]){
        _dateTextField.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:datePicker.date]];
        [_dateTextField resignFirstResponder];
    } else if( [_scanTextField isFirstResponder]){
        _scanTextField.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:lastScannedPicker.date]];
        [_scanTextField resignFirstResponder];
    } else if([_endDateTextField isFirstResponder]){
        _endDateTextField.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:endDatePicker.date]];
        [_endDateTextField resignFirstResponder];
    } else if ([_endScanTextField isFirstResponder]){
        _endScanTextField.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:endLastScannedPicker.date]];
        [_endScanTextField resignFirstResponder];
    }

}


-(NSArray *)fetchTag{
    NSArray *tag;
    NSError *error;
    NSString *url_string = [NSString stringWithFormat: @"%@inventory.php?method=GET_TAG", URL_HEADER];
    NSLog(@"%@",url_string);
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    
    
    NSString *response = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    
    //NSLog(@"%@",[response substringWithRange:NSMakeRange(1, 1)]);
    
    NSLog(@"%@", response);
    
    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"%@",url_string);
    //NSLog(@"%@",json);
    
    tag = [json valueForKeyPath:@"tag"];
    
    NSLog(@"%@", tag);
    
    return tag;
}

-(NSArray *)fetchCat{
    NSArray *cat;
    NSError *error;
    NSString *url_string = [NSString stringWithFormat: @"%@inventory.php?method=GET_CAT", URL_HEADER];
    NSLog(@"%@",url_string);
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    
    
    NSString *response = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    
    //NSLog(@"%@",[response substringWithRange:NSMakeRange(1, 1)]);
    
    NSLog(@"%@", response);
    
    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"%@",url_string);
    //NSLog(@"%@",json);
    
    cat = [json valueForKeyPath:@"category"];
    
    NSLog(@"%@", cat);
    
    return cat;
}

- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(_catTextField.isFirstResponder){
        return [pickerDataCategory2 count];
    }
    else{
        return [pickerDataTag count];
    }
    
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(_catTextField.isFirstResponder){
        return [pickerDataCategory2 objectAtIndex:row];
    } else {
        return [pickerDataTag objectAtIndex:row];
    }
    
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(_catTextField.isFirstResponder){
        self.catTextField.text = [pickerDataCategory2 objectAtIndex:row];
        [self.catTextField endEditing:YES];
    } else {
        self.tagTextField.text = [pickerDataTag objectAtIndex:row];
        [self.tagTextField endEditing:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"resultSegue"])
    {
        filterResult *vc = (filterResult *)[segue destinationViewController];
        [vc setItems:filterItems];
        vc.title = @"Results";
    }
}


-(NSString*) addCat: (NSString*) cat{
    NSError *error;
    NSString *url_string = [NSString stringWithFormat: @"%@inventory.php?method=ADD_CAT&cat=%@", URL_HEADER, cat];
    NSLog(@"%@",url_string);
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    
    
    NSString *response = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    
    //NSLog(@"%@",[response substringWithRange:NSMakeRange(1, 1)]);
    
    NSLog(@"%@", response);
    
    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"%@",url_string);
    //NSLog(@"%@",json);
    
    NSString *result = [json valueForKeyPath:@"success"];
    
    return result;
    
}

-(NSString*) addTag: (NSString*) tag{
    NSError *error;
    NSString *url_string = [NSString stringWithFormat: @"%@inventory.php?method=ADD_TAG&tag=%@", URL_HEADER, tag];
    NSLog(@"%@",url_string);
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    
    
    NSString *response = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    
    //NSLog(@"%@",[response substringWithRange:NSMakeRange(1, 1)]);
    
    NSLog(@"%@", response);
    
    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"%@",url_string);
    //NSLog(@"%@",json);
    
    NSString *result = [json valueForKeyPath:@"success"];
    
    return result;
    
}

//send the dictionary to php
-(void) filterResult: (NSDictionary*) dict{
    NSError *error;
    NSString *invt = dict[@"inv_name"];
    NSString *item = dict[@"item_name"];
    if([item length]>1){
        item= [item stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    }
    NSString *part = dict[@"part_number"];
    if([part length] >1){
        part= [part stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    }
    NSString *cat = dict[@"item_cat"];
    if([cat length]>1){
        cat= [cat stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    }
    NSString *tag = dict[@"item_tag"];
    if([tag length]>1){
        tag= [tag stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    }
    NSString *date = dict[@"insp_date"];
    if([date length] >1){
        date =[date stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    }
    NSString *end_date = dict[@"insp_end_date"];
    if([end_date length]>1){
        end_date =[end_date stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    }
    NSString *scanTime = dict[@"scan"];
    if([scanTime length] >1){
        scanTime = [scanTime stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    }
    NSString *end_scan = dict[@"end_scan"];
    if([end_scan length]>1){
        end_scan = [end_scan stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    }
    
    NSString *url_string = [NSString stringWithFormat: @"%@inventory.php?method=FILTER&inv=%@&item=%@&part=%@&cat=%@&tag=%@&date=%@&end_date=%@&scan=%@&end_scan=%@", URL_HEADER, invt, item, part, cat, tag, date, end_date, scanTime, end_scan];
    NSLog(@"%@", url_string);
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    NSString *response = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    
    filteredData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSMutableArray *result = [filteredData valueForKeyPath:@"item"];
    
    NSLog(@"result: %@", result);
    
    filterItems = result;
    
}
- (void)dealloc {
    [_searchBtn release];
    [_catTextField release];
    [_tagTextField release];
    [_addCatBtn release];
    [_addTagBtn release];
    [_dateTextField release];
    [_itemTextField release];
    [_partNumberTextField release];
    [_scanTextField release];
    [_resetBtn release];
    [scroller release];
    [_endDateTextField release];
    [_endScanTextField release];
    [super dealloc];
}
//store the filtering criterias to a dictionary
- (IBAction)searchAct:(id)sender {
    NSDictionary *filter = [[NSDictionary alloc] initWithObjectsAndKeys:
              _inv, @"inv_name",
              _itemTextField.text, @"item_name",
              _partNumberTextField.text, @"part_number",
              _catTextField.text, @"item_cat",
              _tagTextField.text, @"item_tag",
              _dateTextField.text, @"insp_date",
              _endDateTextField.text, @"insp_end_date",
              _scanTextField.text, @"scan",
              _endScanTextField.text, @"end_scan", nil];
    NSLog(@"%@", filter);
    [self filterResult:filter];
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    filterResult *vc = [story instantiateViewControllerWithIdentifier:@"filterResult"];
    
    vc.items = filterItems;
    vc.dataArray = filteredData;
    vc.title = @"Results";
    
    [self.navigationController pushViewController:vc animated:YES];

}


- (IBAction)addCatAct:(id)sender {
    
    NSString *send = _catTextField.text;
    NSLog(@"%@", [self addCat:send]);
    
}
- (IBAction)addTagAct:(id)sender {
    NSString *send = _tagTextField.text;
    NSLog(@"%@", [self addTag:send]);
}


- (IBAction)resetAct:(id)sender {
    _itemTextField.text = @"";
    _partNumberTextField.text = @"";
    _catTextField.text = @"";
    _tagTextField.text = @"";
    _dateTextField.text = @"";
    _scanTextField.text = @"";
    _endDateTextField.text = @"";
    _endScanTextField.text = @"";
}
@end
