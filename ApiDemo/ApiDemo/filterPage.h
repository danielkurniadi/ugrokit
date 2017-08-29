//
//  filterPage.h
//  ApiDemo
//
//  Created by Student 3 on 28/5/17.
//  Copyright © 2017 U Grok It. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface filterPage : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>{
    IBOutlet UIPickerView *pickerViewCategory2;
    NSArray *pickerDataCategory2;
    IBOutlet UIPickerView *pickerViewTag;
    NSArray *pickerDataTag;
    UIDatePicker *datePicker;
    UIDatePicker *endDatePicker;
    UIDatePicker *lastScannedPicker;
    UIDatePicker *endLastScannedPicker;
    IBOutlet UIScrollView *scroller;
}

@property(nonatomic, strong) NSString *inv;
@property (retain, nonatomic) IBOutlet UITextField *itemTextField;
@property (retain, nonatomic) IBOutlet UITextField *partNumberTextField;

@property (retain, nonatomic) IBOutlet UIButton *searchBtn;

- (IBAction)searchAct:(id)sender;

@property (retain, nonatomic) IBOutlet UITextField *catTextField;
@property (retain, nonatomic) IBOutlet UITextField *tagTextField;
@property (retain, nonatomic) IBOutlet UIButton *addCatBtn;
- (IBAction)addCatAct:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *addTagBtn;

- (IBAction)addTagAct:(id)sender;

@property (retain, nonatomic) IBOutlet UITextField *dateTextField;

@property (retain, nonatomic) IBOutlet UITextField *scanTextField;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *resetBtn;
- (IBAction)resetAct:(id)sender;

@property (retain, nonatomic) IBOutlet UITextField *endDateTextField;

@property (retain, nonatomic) IBOutlet UITextField *endScanTextField;


@end
