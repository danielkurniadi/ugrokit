//
//  main.m
//  ApiDemo
//
//  Created by Tony Requist on 3/9/16.
//  Copyright © 2016 U Grok It. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Ugi.h"

int main(int argc, char * argv[]) {
  @autoreleasepool {
    //
    // Use the standard configuration handling
    //
    [Ugi createSingleton];
    //
    // to control Internet use
    //
    //[Ugi singleton].configurationDelegate.sendGrokkerSerialNumber = NO;
    //[Ugi singleton].configurationDelegate.doAutomaticFirmwareUpdate = NO;
    //[Ugi singleton].configurationDelegate.specificRegionsForGrokkerInitialization = [NSArray arrayWithObjects:@"FCC (US), IC (Canada)", @"ETSI (EU)", nil];
    //
    // to set additional logging
    //
    //[Ugi singleton].loggingStatus = UGI_LOGGING_STATE | UGI_LOGGING_INVENTORY;
    //
    // to capture logging
    //
    //[Ugi setLoggingCallback:^(NSString * _Nonnull string) {
    //  NSLog(@"API DEMO: %@", string);
    //}];

    return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
  }
}
