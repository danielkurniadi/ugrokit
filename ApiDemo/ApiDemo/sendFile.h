//
//  sendFile.h
//  ApiDemo
//
//  Created by Student 3 on 10/7/17.
//  Copyright © 2017 U Grok It. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface sendFile : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>{
    IBOutlet UIPickerView *pickerViewSender;
    NSArray *pickerDataSender;
    
    IBOutlet UIPickerView *pickerViewRecipient;
    NSArray *pickerDataRecipient;
}

@property(nonatomic, strong) NSMutableArray *dataArray;
@property (retain, nonatomic) IBOutlet UITextField *fileNameTF;
@property (retain, nonatomic) IBOutlet UITextField *senderTF;
@property (retain, nonatomic) IBOutlet UITextField *recipientTF;
@property (retain, nonatomic) IBOutlet UITextField *messageTF;

@property (retain, nonatomic) IBOutlet UIButton *sendBtn;

- (IBAction)sendAct:(id)sender;

@end
