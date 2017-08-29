//
//  ViewController.m
//
//  Copyright (c) 2013 U Grok It
//

#import "ViewController.h"
#import "Ugi.h"
#import "UgiUtil.h"
#import "UgiRfMicron.h"
#import "Ugi_regions.h"
#import "UgiInventory.h"
#import "UgiFooterView.h"
#import "UgiTitleView.h"
#import "UgiTagReadHistoryView.h"
#import "UgiTagCell.h"

@import AudioToolbox;
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#define SPECIAL_FUNCTION_NONE 0
#define SPECIAL_FUNCTION_READ_USER_MEMORY 1
#define SPECIAL_FUNCTION_READ_TID_MEMORY 2
#define SPECIAL_FUNCTION_READ_RF_MICRON_MAGNUS_SENSOR_CODE 3
  #define SPECIAL_FUNCTION_RF_MICRON_MAGNUS_TYPE UGI_RF_MICRON_MAGNUS_MODEL_402
  #define SPECIAL_FUNCTION_RF_MICRON_MAGNUS_LIMIT_TYPE UGI_RF_MICRON_MAGNUS_LIMIT_TYPE_LESS_THAN_OR_EQUAL
  #define SPECIAL_FUNCTION_RF_MICRON_MAGNUS_LIMIT_THRESHOLD 31
#define SPECIAL_FUNCTION_READ_RF_MICRON_MAGNUS_TEMPERATURE 4

///////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private
///////////////////////////////////////////////////////////////////////////////////////

@interface ViewController ()

@property (retain, nonatomic) IBOutlet UILabel *foundLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UIButton *actionsButton;
@property (retain, nonatomic) IBOutlet UITableView *tagTableView;
@property (retain, nonatomic) IBOutlet UgiFooterView *footer;

@property (nonatomic) UgiInventoryTypes inventoryType;
@property (nonatomic) int specialFunction;

@property (retain, nonatomic) NSMutableArray<UgiTag *> *displayedTags;
@property (retain, nonatomic) NSMutableDictionary<UgiEpc *, UgiTagCell *> *epcToCellMap;
@property (retain, nonatomic) NSMutableDictionary<UgiEpc *, NSMutableString *> *epcToDetailString;

@property (retain, nonatomic) NSTimer *timer;


@end

//inventory.tags = array of epc tag

///////////////////////////////////////////////////////////////////////////////////////
#pragma mark - implementation
///////////////////////////////////////////////////////////////////////////////////////

@implementation ViewController

- (void)dealloc {
  [_footer release];
  [_foundLabel release];
  [_timeLabel release];
  [_displayedTags release];
  [_epcToCellMap release];
  [_epcToDetailString release];
  [_tagTableView release];
  [_timer release];
  [_actionsButton release];
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.titleView.batteryStatusIndicatorDisplayVersionInfoOnTouch = YES;
  self.titleView.useBackgroundBasedOnUiColor = YES;
  self.titleView.displayWaveAnimationWhileScanning = YES;
  self.displayDialogIfDisconnected = YES;

  self.inventoryType = UGI_INVENTORY_TYPE_LOCATE_DISTANCE;
  self.specialFunction = SPECIAL_FUNCTION_NONE;
  self.displayedTags = [NSMutableArray array];
  self.epcToCellMap = [NSMutableDictionary dictionary];
  self.epcToDetailString = [NSMutableDictionary dictionary];
  self.foundLabel.text = @"0";
  [self updateUI];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return [Ugi singleton].supportedInterfaceOrientationsAllowRotationOnTablet;
}

///////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UI
///////////////////////////////////////////////////////////////////////////////////////


- (void) updateUI {
  UgiInventory *inventory = [Ugi singleton].activeInventory;   //--> the inventory
  self.actionsButton.enabled = (inventory == nil);
  if (inventory) {
    //
    // Scanning
    //
    if (inventory.isPaused) {
      [self.footer setLeftText:NSLocalizedStringWithDefaultValue(@"FooterResume", @"Localizable", [NSBundle mainBundle], @"resume", @"Footer button: resume") withCompletion:^{
        [inventory resumeInventory];
        [self updateUI];
      }];
    } else {
      [self.footer setLeftText:NSLocalizedStringWithDefaultValue(@"FooterPause", @"Localizable", [NSBundle mainBundle], @"pause", @"Footer button: resume") withCompletion:^{
        [inventory pauseInventory];
        [self updateUI];
      }];
    }
    [self.footer setCenterText:NSLocalizedStringWithDefaultValue(@"FooterStop", @"Localizable", [NSBundle mainBundle], @"stop", @"Footer button: stop") withCompletion:^{
      [self stopScanning];
    }];
    [self.footer setRightText:nil withCompletion:nil];
  } else {
    //
    // Not scanning
    //
    [self.footer setLeftText:NSLocalizedStringWithDefaultValue(@"FooterInfo", @"Localizable", [NSBundle mainBundle], @"info", @"Footer button: info") withCompletion:^{
      [UgiUiUtil showVersionAlertWithTitle:nil withShowExtraInfo:NO];
    }];
    [self.footer setCenterText:NSLocalizedStringWithDefaultValue(@"FooterStart", @"Localizable", [NSBundle mainBundle], @"start", @"Footer button: start") withCompletion:^{
      [self startScanning];
    }];
    [self.footer setRightText:NSLocalizedStringWithDefaultValue(@"FooterConfigure", @"Localizable", [NSBundle mainBundle], @"configure", @"Footer button: configure") withCompletion:^{
      [self doConfigure];
    }];
  }
}

- (void) updateCountAndTime {
  self.foundLabel.text = [NSString stringWithFormat:@"%d", (int)self.displayedTags.count];
  if ([Ugi singleton].activeInventory) {
    NSTimeInterval interval = -[[Ugi singleton].activeInventory.startTime timeIntervalSinceNow];
    int minutes = interval / 60;
    int seconds = interval - minutes*60;
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
  }
}

///////////////////////////////////////////////////////////////////////////////////////
#pragma mark - scanning
///////////////////////////////////////////////////////////////////////////////////////

- (void) startScanning {
  [self.displayedTags removeAllObjects];
  [self.epcToCellMap removeAllObjects];
  [self.epcToDetailString removeAllObjects];
  [self.tagTableView reloadData];
  
  UgiRfidConfiguration *config;
  if (self.specialFunction == SPECIAL_FUNCTION_READ_RF_MICRON_MAGNUS_SENSOR_CODE) {
    config = [UgiRfMicron configToReadMagnusSensorValue:UGI_INVENTORY_TYPE_LOCATE_DISTANCE
                                           withTagModel:SPECIAL_FUNCTION_RF_MICRON_MAGNUS_TYPE
                                      withRssiLimitType:SPECIAL_FUNCTION_RF_MICRON_MAGNUS_LIMIT_TYPE
                                 withLimitRssiThreshold:SPECIAL_FUNCTION_RF_MICRON_MAGNUS_LIMIT_THRESHOLD];
  } else if (self.specialFunction == SPECIAL_FUNCTION_READ_RF_MICRON_MAGNUS_TEMPERATURE) {
    config = [UgiRfMicron configToReadMagnusTemperature:UGI_INVENTORY_TYPE_LOCATE_DISTANCE];
  } else {
    config = [UgiRfidConfiguration configWithInventoryType:self.inventoryType];
    if (self.specialFunction == SPECIAL_FUNCTION_READ_USER_MEMORY) {
      config.minUserBytes = config.maxUserBytes = 64;
    } else if (self.specialFunction == SPECIAL_FUNCTION_READ_TID_MEMORY) {
      config.minTidBytes = config.maxTidBytes = 24;
    }
  }
  [[Ugi singleton] startInventory:self withConfiguration:config];

  [self updateUI];
  [self updateCountAndTime];
  if (!config.reportSubsequentFinds) {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(updateCountAndTime)
                                                userInfo:nil
                                                 repeats:YES];
  }
}

- (void) disconnectedDialogCancelled {
  [self stopScanning];
}

- (void) stopScanning {
  [self.timer invalidate];
  self.timer = nil;
  [UgiUiUtil stopInventoryWithCompletionShowWaiting:^{
    [self updateUI];
  }];
}

///////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Inventory
///////////////////////////////////////////////////////////////////////////////////////

- (void) inventoryHistoryInterval {
  [self.tagTableView setNeedsDisplayForAllVisibleCells];
  [self updateCountAndTime];
}

- (void) inventoryTagFound:(UgiTag *)tag
   withDetailedPerReadData:(NSArray<UgiDetailedPerReadData *> *)detailedPerReadData {
  [self.displayedTags addObject:tag];
  [self.tagTableView appendRow:YES];
  self.epcToDetailString[tag.epc] = [NSMutableString string];
  [self handlePerReads:tag withDetailedPerReadData:detailedPerReadData];
  [self updateCountAndTime];
}

- (void) inventoryTagSubsequentFinds:(UgiTag *)tag numFinds:(int)num
             withDetailedPerReadData:(NSArray<UgiDetailedPerReadData *> *)detailedPerReadData {
  [self handlePerReads:tag withDetailedPerReadData:detailedPerReadData];
}

- (void) handlePerReads:(UgiTag *)tag
withDetailedPerReadData:(NSArray<UgiDetailedPerReadData *> *)detailedPerReadData {
  if (self.specialFunction == SPECIAL_FUNCTION_READ_RF_MICRON_MAGNUS_SENSOR_CODE) {
    for (UgiDetailedPerReadData *p in detailedPerReadData) {
      //
      // get sensor code and add it to the string we display
      //
      int sensorCode = [UgiRfMicron getMagnusSensorCode:p];
      NSMutableString *s = self.epcToDetailString[tag.epc];
      if (s.length) [s appendString:@" "];
      [s appendFormat:@"%d", sensorCode];
      if (SPECIAL_FUNCTION_RF_MICRON_MAGNUS_LIMIT_TYPE != UGI_RF_MICRON_MAGNUS_LIMIT_TYPE_NONE) {
        //
        // get on-chip RSSI and add it to the string we display
        //
        int onChipRssi = [UgiRfMicron getMagnusOnChipRssi:p];
        [s appendFormat:@"/%d", onChipRssi];
      }
      UgiTagCell *cell = self.epcToCellMap[tag.epc];
      if (cell) cell.detail = s;
    }
  } else if (self.specialFunction == SPECIAL_FUNCTION_READ_RF_MICRON_MAGNUS_TEMPERATURE) {
    for (UgiDetailedPerReadData *p in detailedPerReadData) {
      //
      // Get the temperature and add it to string we display
      //
      double temperatureC = [UgiRfMicron getMagnusTemperature:tag perReadData:p];
      NSMutableString *s = self.epcToDetailString[tag.epc];
      if (s.length) [s appendString:@" "];
      if (temperatureC == -999) {
        // invalid
        [s appendString:@"(invalid)"];
      } else {
        [s appendFormat:@"%0.1f", temperatureC];
      }
      UgiTagCell *cell = self.epcToCellMap[tag.epc];
      if (cell) cell.detail = s;
    }
  }
}

- (void) inventoryDidStopWithResult:(UgiInventoryCompletedReturnValues)result {
  if ((result != UGI_INVENTORY_COMPLETED_LOST_CONNECTION) && (result != UGI_INVENTORY_COMPLETED_OK)) {
    [UgiUiUtil showInventoryError:result];
  }
  [self.timer invalidate];
  self.timer = nil;
  [self updateUI];
}

///////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table view
///////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.displayedTags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UgiTagCell *cell = [self.tagTableView dequeueReusableCellWithIdentifier:@"TagTableCell"];
  cell.accessoryType = UITableViewCellAccessoryNone;
  cell.detail = nil;
  
  UgiTag *tag = self.displayedTags[indexPath.row];
  self.epcToCellMap[tag.epc] = cell;
  cell.displayTag = tag;
  cell.themeColor = self.themeColor;
  cell.title = tag.epc.toString;
  NSMutableString *s = self.epcToDetailString[tag.epc];
  if (s.length > 0) {
    cell.detail = s;
  } else if (self.specialFunction == SPECIAL_FUNCTION_READ_USER_MEMORY) {
    cell.detail = [NSString stringWithFormat:@"user: %@", [UgiUtil dataToString:tag.userMemory]];
  } else if (self.specialFunction == SPECIAL_FUNCTION_READ_TID_MEMORY) {
    cell.detail = [NSString stringWithFormat:@"tid: %@", [UgiUtil dataToString:tag.tidMemory]];
  }
  return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UgiTag *tag = self.displayedTags[indexPath.row];
  [self tagTouched:tag];
}

///////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Tag actions
///////////////////////////////////////////////////////////////////////////////////////

- (void)tagTouched:(UgiTag *)tag {
  UgiInventory *inventory = [Ugi singleton].activeInventory;
  if (inventory) {
    if (!inventory.isPaused) [inventory pauseInventory];
    [UgiUiUtil
     showMenuWithTitle:nil
     withCancelCompletion:^{
       [inventory resumeInventory];
       [self updateUI];
     } withItems:[NSArray arrayWithObjects:
                [UgiMenuItem itemWithTitle:@"commission (write EPC)"
                               withHandler:^{
                                 [self doCommission:tag];
                               }],
                [UgiMenuItem itemWithTitle:@"read user memory"
                               withHandler:^{
                                 [self doReadUserMemory:tag];
                               }],
                [UgiMenuItem itemWithTitle:@"write user memory"
                               withHandler:^{
                                 [self doWriteUserMemory:tag];
                               }],
                [UgiMenuItem itemWithTitle:@"read then write user memory"
                               withHandler:^{
                                 [self doReadThenWriteUserMemory:tag];
                               }],
                [UgiMenuItem itemWithTitle:@"scan for this tag only"
                               withHandler:^{
                                 [self doLocate:tag];
                               }],
                nil]];
  } else {
    [UgiUiUtil showOk:@"not scanning"
              message:@"Touch a tag while scanning (or paused) to act on the tag"];
  }
}

// All tag actions called with inventory paused

- (void)doCommission:(UgiTag *)tag {
  [UgiUiUtil showTextInput:@"commission tag"
                   message:@"EPC:"
         actionButtonTitle:@"commission"
               initialText:tag.epc.toString
       allowAutoCorrection:NO
              keyboardType:UIKeyboardTypeDefault
                switchText:nil
        switchInitialValue:NO
            withCompletion:^(NSString *text, BOOL switchValue) {
              [[Ugi singleton].activeInventory resumeInventory];
              [self updateUI];
              UgiEpc *newEpc = [UgiEpc epcFromString:text];
              [UgiUiUtil showWaiting:@"commissioning"];
              [[Ugi singleton].activeInventory
               programTag:tag.epc
               toEpc:newEpc
               withPassword:UGI_NO_PASSWORD
               whenCompleted:^(UgiTag *tag, UgiTagAccessReturnValues result) {
                 [UgiUiUtil hideWaiting];
                 NSString *message = (result == UGI_TAG_ACCESS_OK)
                 ? [NSString stringWithFormat:@"Successful\nNew EPC: %@", [tag.epc toString]]
                 : [UgiUiUtil tagAccessErrorMessageForTagAccessReturnValue:result];
                 [UgiUiUtil showOk:@"commission tag"
                           message:message];
               }];
            } withCancelCompletion:^{
              [[Ugi singleton].activeInventory resumeInventory];
              [self updateUI];
            } withShouldEnableForTextCompletion:^BOOL(NSString *text) {
              if ((text.length == 0) || (text.length > tag.epc.toString.length)) return NO;
              NSRegularExpression *regex = [[[NSRegularExpression alloc] initWithPattern:@"^[0-9a-fA-F]*$" options:0 error:nil] autorelease];
              return [regex numberOfMatchesInString:text options:0 range:NSMakeRange(0, text.length)] == 1;
            }];
}

- (void)doReadUserMemory:(UgiTag *)tag {
  [[Ugi singleton].activeInventory resumeInventory];
  [self updateUI];
  [UgiUiUtil showWaiting:@"reading user memory"];
  NSDate *start = [NSDate date];
  [[Ugi singleton].activeInventory
   readTag:tag.epc
   memoryBank:UGI_MEMORY_BANK_USER
   offset:0
   minNumBytes:16
   maxNumBytes:64
   withPassword:UGI_NO_PASSWORD
   whenCompleted:^(UgiTag *tag, NSData *data, UgiTagAccessReturnValues result) {
     [UgiUiUtil hideWaiting];
     if (result == UGI_TAG_ACCESS_OK) {
       NSTimeInterval elapsed = -[start timeIntervalSinceNow];
       NSString *message = [NSString stringWithFormat:@"Success: %0.1f seconds\nUSER (%lu bytes)\n%@",
                            elapsed,
                            (unsigned long)(data.length),
                            [UgiUtil dataToString:data]];
       [UgiUiUtil showOk:@"read user memory"
                 message:message
           okButtonTitle:@""
          withCompletion:nil];
     } else {
       [UgiUiUtil showOk:@"read user memory"
                 message:[NSString stringWithFormat:@"Error: %@", [UgiUiUtil tagAccessErrorMessageForTagAccessReturnValue:result]]
           okButtonTitle:@""
          withCompletion:nil];
     }
   }];
}

- (void) doWriteUserMemory:(UgiTag *)tag {
  [[Ugi singleton].activeInventory resumeInventory];
  [self updateUI];
  [UgiUiUtil showWaiting:@"writing user memory"];
  NSData *newData = [@"Hello World!" dataUsingEncoding:NSUTF8StringEncoding];
  [[Ugi singleton].activeInventory
   writeTag:tag.epc
   memoryBank:UGI_MEMORY_BANK_USER
   offset:0
   data:newData
   previousData:nil
   withPassword:UGI_NO_PASSWORD
   whenCompleted:^(UgiTag *tag, UgiTagAccessReturnValues result) {
     [UgiUiUtil hideWaiting];
     if (result == UGI_TAG_ACCESS_OK) {
       NSString *message = [NSString stringWithFormat:@"Success\nUSER (%lu bytes)\n%@",
                            (unsigned long)(newData.length),
                            [UgiUtil dataToString:newData]];
       [UgiUiUtil showOk:@"write user memory"
                 message:message
           okButtonTitle:@""
          withCompletion:nil];
     } else {
       [UgiUiUtil showOk:@"write user memory"
                 message:[NSString stringWithFormat:@"Error: %@", [UgiUiUtil tagAccessErrorMessageForTagAccessReturnValue:result]]
           okButtonTitle:@""
          withCompletion:nil];
     }
   }];
}

- (void)doReadThenWriteUserMemory:(UgiTag *)tag {
  [[Ugi singleton].activeInventory resumeInventory];
  [self updateUI];
  [UgiUiUtil showWaiting:@"reading user memory"];
  [[Ugi singleton].activeInventory
   readTag:tag.epc
   memoryBank:UGI_MEMORY_BANK_USER
   offset:0
   minNumBytes:16
   maxNumBytes:64
   withPassword:UGI_NO_PASSWORD
   whenCompleted:^(UgiTag *tag, NSData *data, UgiTagAccessReturnValues result) {
     [UgiUiUtil hideWaiting];
     if (result == UGI_TAG_ACCESS_OK) {
       uint8_t buf[data.length];
       [data getBytes:buf];
       uint8_t temp = buf[0];
       memmove(buf, buf+1, data.length-1);
       buf[data.length-1] = temp;
       NSData *newData = [NSData dataWithBytes:buf length:data.length];
       [UgiUiUtil showWaiting:@"writing user memory"];
       [[Ugi singleton].activeInventory
        writeTag:tag.epc
        memoryBank:UGI_MEMORY_BANK_USER
        offset:0
        data:newData
        previousData:data
        withPassword:UGI_NO_PASSWORD
        whenCompleted:^(UgiTag *tag, UgiTagAccessReturnValues result) {
          [UgiUiUtil hideWaiting];
          if (result == UGI_TAG_ACCESS_OK) {
            NSString *message = [NSString stringWithFormat:@"Success\nUSER (%lu bytes)\n%@",
                                 (unsigned long)(newData.length),
                                 [UgiUtil dataToString:newData]];
            [UgiUiUtil showOk:@"write user memory"
                      message:message
                okButtonTitle:@""
               withCompletion:nil];
          } else {
            [UgiUiUtil showOk:@"write user memory"
                      message:[NSString stringWithFormat:@"Error writing user memory: %@", [UgiUiUtil tagAccessErrorMessageForTagAccessReturnValue:result]]
                okButtonTitle:@""
               withCompletion:nil];
          }
        }];
     } else {
       [UgiUiUtil showOk:@"read user memory"
                 message:[NSString stringWithFormat:@"Error reading user memory: %@", [UgiUiUtil tagAccessErrorMessageForTagAccessReturnValue:result]]
           okButtonTitle:@""
          withCompletion:nil];
     }
   }];
}

- (void) doLocate:(UgiTag *)tag {
  [self.timer invalidate];
  self.timer = nil;
  [UgiUiUtil stopInventoryWithCompletionShowWaiting:^{
    [self.displayedTags removeAllObjects];
    [self.epcToCellMap removeAllObjects];
    [self.epcToDetailString removeAllObjects];
    [self.tagTableView reloadData];

    UgiRfidConfiguration *config = [UgiRfidConfiguration configWithInventoryType:UGI_INVENTORY_TYPE_LOCATE_DISTANCE];
    config.selectMask = tag.epc.data;
    config.selectOffset = 32;
    config.selectBank = UGI_MEMORY_BANK_EPC;
    [[Ugi singleton] startInventory:self
                  withConfiguration:config
                            withEpc:tag.epc];
    [self updateUI];
    [UgiUiUtil showToast:@"Restarted inventory"
                 message:[NSString stringWithFormat:@"Searching only for %@", tag.epc.toString]];
  }];
}


///////////////////////////////////////////////////////////////////////////////////////
#pragma mark - configuration
///////////////////////////////////////////////////////////////////////////////////////

- (void) doConfigure {
  [UgiUiUtil
   showMenuWithTitle:@"configure"
   withCancelCompletion:nil
   withItems:[NSArray arrayWithObjects:
              [UgiMenuItem itemWithTitle:@"inventory type"
                             withHandler:^{
                               NSMutableArray *types = [NSMutableArray array];
                               for (int i = 0; i < [UgiRfidConfiguration numInventoryTypes]; i++) {
                                 [types addObject:[UgiRfidConfiguration nameForInventoryType:i+1]];
                               }
                               [UgiUiUtil showChoices:types
                             withInitialSelectedIndex:self.inventoryType-1
                                            withTitle:@"inventory type"
                                          withMessage:nil
                                withActionButtonTitle:@"set type"
                                        withCanCancel:YES
                                       withCompletion:^(int index, NSString *regionName) {
                                         self.inventoryType = index+1;
                                       } withConfirmationCompletion:nil
                                 withCancelCompletion:nil];
                             }],
              [UgiMenuItem itemWithTitle:@"special functions"
                             withHandler:^{
                               [UgiUiUtil showChoices:[NSArray arrayWithObjects:@"none",
                                                       @"read User Memory",
                                                       @"read TID memory",
                                                       @"read RF Micron sensor code",
                                                       @"read RF Micron temperature", nil]
                             withInitialSelectedIndex:self.specialFunction
                                            withTitle:@"special function"
                                          withMessage:nil
                                withActionButtonTitle:@"set"
                                        withCanCancel:YES
                                       withCompletion:^(int index, NSString *regionName) {
                                         self.specialFunction = index;
                                       } withConfirmationCompletion:nil
                                 withCancelCompletion:nil];
                             }],
              nil]];
}

///////////////////////////////////////////////////////////////////////////////////////
#pragma mark - actions
///////////////////////////////////////////////////////////////////////////////////////

- (IBAction)doActions:(id)sender {
  [UgiUiUtil
   showMenuWithTitle:@"choose action"
   withCancelCompletion:nil
   withItems:[NSArray arrayWithObjects:
              [UgiMenuItem itemWithTitle:@"Set Region"
                             withHandler:^{
                               [[Ugi singleton] invokeSetRegion];
                             }],
              [UgiMenuItem itemWithTitle:@"Save Inventory"
                             withHandler:^{
                                 [self performSegueWithIdentifier:@"secondPageSegue" sender:self];
                             }],
              [UgiMenuItem itemWithTitle:@"Download Inventory"
                             withHandler:^{
                               [self performSegueWithIdentifier:@"downloadInvSegue" sender:self];
                             }],
              nil]];
}

@end
