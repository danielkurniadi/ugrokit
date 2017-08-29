//
//  SecondPageViewController.m
//
//  Copyright (c) 2013 U Grok It
//

#import "SecondPageViewController.h"
#import "Ugi.h"
#import "UgiFooterView.h"
#import "UgiTitleView.h"
#import "Constants.h"

///////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private
///////////////////////////////////////////////////////////////////////////////////////

@interface SecondPageViewController ()

@property (retain, nonatomic) IBOutlet UgiFooterView *footer;

@end

///////////////////////////////////////////////////////////////////////////////////////
#pragma mark - implementation
///////////////////////////////////////////////////////////////////////////////////////

@implementation SecondPageViewController{
    NSArray *inv_list;
    NSArray *categories;
}

- (void)dealloc {
  [_footer release];
    [_SaveBtn release];
    [_pickerCatTextField release];
    [_invName release];
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
    
    self.title = @"Save Inventory";
    categories = [[NSArray alloc] initWithObjects:@"Other", @"A",@"B", @"C", @"D", nil];
    
  self.themeColor = [UIColor colorFromHexString:@"F58026"];
  self.themeColor = [UIColor colorFromHexString:@"ffcc00"];  ///////////////////

  [self.titleView setRightButtonImage:[UIImage imageNamed:@"btn_second_page_right.png"]
                            withColor:nil
                 withHighlightedImage:nil
                 withHighlightedColor:nil
                       withCompletion:^{
                         UgiLog(@"right button touched");
                       }];
/*
  [self.footer setCenterText:@"back" withCompletion:^{
    [self goBack];
  }];
  [self.footer setLeftText:@"info" withCompletion:^{
    [UgiUiUtil showVersionAlertWithTitle:nil withShowExtraInfo:NO];
  }];*/
    
    pickerDataCategory = [[NSArray alloc] initWithObjects:@"Other", @"A", @"B", @"C", @"D", nil];
    
    UIPickerView *picker = [[UIPickerView alloc] init];
    picker.dataSource = self;
    picker.delegate = self;
    [picker setShowsSelectionIndicator:YES];
    [self.pickerCatTextField setInputView:picker];
    
}

- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [pickerDataCategory count];
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [pickerDataCategory objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.pickerCatTextField.text = [pickerDataCategory objectAtIndex:row];
}

-(bool) addInv{
    NSError *error;
    NSString *inv_name = self.invName.text;
    int *category = [categories indexOfObject:self.pickerCatTextField.text];
    NSInteger *no_item = 10;
    NSString *user = @"dita";
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *st = [dateFormatter stringFromDate:date];
    
    NSString *url_string = [NSString stringWithFormat: @"%@inventory.php?method=ADD_INV&inv=%@&cat=%tu&no_item=%tu&user=%@&st=%@", URL_HEADER, inv_name, category, no_item, user, st];
    
    NSLog(@"%@",url_string);
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    
    
    NSString *response = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    
    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"%@",url_string);
    
    if([[json valueForKey:@"success"] isEqualToString:@"yes"]){
        return 1;
    } else {
        return 0;
    }
    
}

- (IBAction)SaveAct:(id)sender {
    int res = [self addInv];
    NSLog(@"%tu", res);
    
}
@end
