//
//  SecondPageViewController.h
//  ApiDemo
//
//  Created by Tony Requist on 3/9/16.
//  Copyright © 2016 U Grok It. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UgiViewController.h"

@interface SecondPageViewController : UgiViewController<UIPickerViewDelegate, UIPickerViewDataSource>{
    IBOutlet UIPickerView *pickerViewCategory;
    NSArray *pickerDataCategory;
}

@property (retain, nonatomic) IBOutlet UITextField *pickerCatTextField;
@property (retain, nonatomic) IBOutlet UITextField *invName;


@property (retain, nonatomic) IBOutlet UIButton *SaveBtn;

- (IBAction)SaveAct:(id)sender;

@end

