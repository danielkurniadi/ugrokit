//
//  AppDelegate.swift
//  SwiftApiDemo
//
//  Created by Tony Requist on 5/9/16.
//  Copyright © 2016 U Grok It. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
 
  override init() {
    //
    // Use the standard configuration handling
    //
    Ugi.createSingleton()
    //
    // to control Internet use
    //
    //Ugi.singleton().configurationDelegate.sendGrokkerSerialNumber = false
    //Ugi.singleton().configurationDelegate.doAutomaticFirmwareUpdate = false
    //Ugi.singleton().configurationDelegate.specificRegionsForGrokkerInitialization = ["FCC (US), IC (Canada)", "ETSI (EU)"]
    //
    // to set additional logging
    //
    //Ugi.singleton().loggingStatus = [UgiLoggingTypes.UGI_LOGGING_STATE, UgiLoggingTypes.UGI_LOGGING_INVENTORY]
    //
    // Open a connection to the Grokker
    //
    Ugi.singleton().openConnection()
  }

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    return true
  }

  func applicationWillTerminate(application: UIApplication) {
    Ugi.singleton().closeConnection()
  }


}

