//
//  ViewController.swift
//  SwiftApiDemo
//
//  Created by Tony Requist on 5/9/16.
//  Copyright © 2016 U Grok It. All rights reserved.
//

import UIKit

let SPECIAL_FUNCTION_NONE = 0
let SPECIAL_FUNCTION_READ_USER_MEMORY = 1
let SPECIAL_FUNCTION_READ_TID_MEMORY = 2
let SPECIAL_FUNCTION_READ_RF_MICRON_MAGNUS_SENSOR_CODE = 3
let SPECIAL_FUNCTION_RF_MICRON_MAGNUS_TYPE = UgiRfMicronMagnusModels.UGI_RF_MICRON_MAGNUS_MODEL_402
let SPECIAL_FUNCTION_RF_MICRON_MAGNUS_LIMIT_TYPE = UgiRfMicronMagnusRssiLimitTypes.UGI_RF_MICRON_MAGNUS_LIMIT_TYPE_LESS_THAN_OR_EQUAL
let SPECIAL_FUNCTION_RF_MICRON_MAGNUS_LIMIT_THRESHOLD: Int32 = 31
let SPECIAL_FUNCTION_READ_RF_MICRON_MAGNUS_TEMPERATURE = 4

class ViewController: UgiViewController, UITableViewDelegate, UITableViewDataSource, UgiInventoryDelegate {
  
  ///////////////////////////////////////////////////////////////////////////////////////
  // Private
  ///////////////////////////////////////////////////////////////////////////////////////

  @IBOutlet weak var foundLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var actionsButton: UgiButton!
  @IBOutlet weak var tagTableView: UITableView!
  @IBOutlet weak var footer: UgiFooterView!

  var inventoryType: UgiInventoryTypes = UgiInventoryTypes.UGI_INVENTORY_TYPE_LOCATE_DISTANCE
  var specialFunction: Int = SPECIAL_FUNCTION_NONE
  
  var displayedTags: [UgiTag] = []
  var tagToCellMap: [UgiTag : UgiTagCell] = [:]
  var tagToDetailString: [UgiTag : NSMutableString] = [:]

  var timer: NSTimer = NSTimer()


  ///////////////////////////////////////////////////////////////////////////////////////
  // Lifecycle
  ///////////////////////////////////////////////////////////////////////////////////////

  override func viewDidLoad() {
    super.viewDidLoad()
    self.titleView!.batteryStatusIndicatorDisplayVersionInfoOnTouch = true
    self.titleView!.useBackgroundBasedOnUiColor = true
    self.titleView!.displayWaveAnimationWhileScanning = true
    self.displayDialogIfDisconnected = true
    self.foundLabel.text = "0"
    self.updateUI()
  }
  
  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return Ugi.singleton().supportedInterfaceOrientationsWithAllowRotationOnTablet(true)
  }

  ///////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////


  func updateUI() {
    let inventory: UgiInventory? = Ugi.singleton().activeInventory
    self.actionsButton.enabled = (inventory == nil)
    if inventory != nil {
      //
      // Scanning
      //
      if inventory!.isPaused {
        self.footer.setLeftText(NSLocalizedString("FooterResume", value: "resume", comment: "Footer button: resume"), withCompletion: {() -> Void in
          inventory!.resumeInventory()
          self.updateUI()
        })
      }
      else {
        self.footer.setLeftText(NSLocalizedString("FooterPause", value: "pause", comment: "Footer button: resume"), withCompletion: {() -> Void in
          inventory!.pauseInventory()
          self.updateUI()
        })
      }
      self.footer.setCenterText(NSLocalizedString("FooterStop", value: "stop", comment: "Footer button: stop"), withCompletion: {() -> Void in
        self.stopScanning()
      })
      self.footer.setRightText(nil, withCompletion: nil)
    }
    else {
      //
      // Not scanning
      //
      self.footer.setLeftText(NSLocalizedString("FooterInfo", value: "info", comment: "Footer button: info"), withCompletion: {() -> Void in
        UgiUiUtil.showVersionAlertWithTitle(nil, withShowExtraInfo: false)
      })
      self.footer.setCenterText(NSLocalizedString("FooterStart", value: "start", comment: "Footer button: start"), withCompletion: {() -> Void in
        self.startScanning()
      })
      self.footer.setRightText(NSLocalizedString("FooterConfigure", value: "configure", comment: "Footer button: configure"), withCompletion: {() -> Void in
        self.doConfigure()
      })
    }
  }
  
  func updateCountAndTime() {
    self.foundLabel.text = "\(Int(self.displayedTags.count))"
    let inventory: UgiInventory? = Ugi.singleton().activeInventory
    if inventory != nil {
      let interval: NSTimeInterval = -Ugi.singleton().activeInventory!.startTime.timeIntervalSinceNow
      let intervalSeconds = Int(interval)
      let minutes: Int = intervalSeconds / 60
      let seconds: Int = intervalSeconds - minutes * 60
      self.timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
  }
  ///////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////
  
  func startScanning() {
    self.displayedTags.removeAll()
    self.tagToCellMap.removeAll()
    self.tagToDetailString.removeAll()
    self.tagTableView.reloadData()
    var config: UgiRfidConfiguration
    if self.specialFunction == SPECIAL_FUNCTION_READ_RF_MICRON_MAGNUS_SENSOR_CODE {
      config = UgiRfMicron.configToReadMagnusSensorValue(
        UgiInventoryTypes.UGI_INVENTORY_TYPE_LOCATE_DISTANCE,
        withTagModel: SPECIAL_FUNCTION_RF_MICRON_MAGNUS_TYPE,
        withRssiLimitType: SPECIAL_FUNCTION_RF_MICRON_MAGNUS_LIMIT_TYPE,
        withLimitRssiThreshold: SPECIAL_FUNCTION_RF_MICRON_MAGNUS_LIMIT_THRESHOLD)
    }
    else if self.specialFunction == SPECIAL_FUNCTION_READ_RF_MICRON_MAGNUS_TEMPERATURE {
      config = UgiRfMicron.configToReadMagnusTemperature(UgiInventoryTypes.UGI_INVENTORY_TYPE_LOCATE_DISTANCE)
    }
    else {
      config = UgiRfidConfiguration.configWithInventoryType(self.inventoryType)
      if self.specialFunction == SPECIAL_FUNCTION_READ_USER_MEMORY {
        config.minUserBytes = 64
        config.maxUserBytes = 64
      }
      else if self.specialFunction == SPECIAL_FUNCTION_READ_TID_MEMORY {
        config.minTidBytes = 24
        config.maxTidBytes = 24
      }
    }
    
    Ugi.singleton().startInventory(self, withConfiguration: config)
    self.updateUI()
    self.updateCountAndTime()
    if !config.reportSubsequentFinds {
      self.timer = NSTimer.scheduledTimerWithTimeInterval(1,
                                                          target: self,
                                                          selector: #selector(ViewController.updateCountAndTime),
                                                          userInfo: nil,
                                                          repeats: true)
    }
  }
  
  override func disconnectedDialogCancelled() {
    self.stopScanning()
  }
  
  func stopScanning() {
    self.timer.invalidate()
    UgiUiUtil.stopInventoryWithCompletionShowWaiting({() -> Void in
      self.updateUI()
    })
  }
  ///////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////
  
  func inventoryHistoryInterval() {
    self.tagTableView.setNeedsDisplayForAllVisibleCells()
    self.updateCountAndTime()
  }
  
  func inventoryTagFound(tag: UgiTag,
                         withDetailedPerReadData detailedPerReadData: [UgiDetailedPerReadData]?) {
    self.displayedTags.append(tag)
    self.tagToDetailString[tag] = NSMutableString()
    self.tagTableView.appendRow(true)
    self.handlePerReads(tag, withDetailedPerReadData: detailedPerReadData)
    self.updateCountAndTime()
  }
  
  func inventoryTagSubsequentFinds(tag: UgiTag,
                                   numFinds num: Int32,
                                            withDetailedPerReadData detailedPerReadData: [UgiDetailedPerReadData]?) {
    self.handlePerReads(tag, withDetailedPerReadData: detailedPerReadData)
  }
  
  func handlePerReads(tag: UgiTag, withDetailedPerReadData detailedPerReadData: [UgiDetailedPerReadData]?) {
    if self.specialFunction == SPECIAL_FUNCTION_READ_RF_MICRON_MAGNUS_SENSOR_CODE {
      for p: UgiDetailedPerReadData in detailedPerReadData! {
        //
        // get sensor code and add it to the string we display
        //
        let sensorCode: Int32 = UgiRfMicron.getMagnusSensorCode(p)
        let s = self.tagToDetailString[tag]!
        if s.length > 0 {
          s.appendString(" ")
        }
        s.appendFormat("%d", sensorCode)
        if SPECIAL_FUNCTION_RF_MICRON_MAGNUS_LIMIT_TYPE != UgiRfMicronMagnusRssiLimitTypes.UGI_RF_MICRON_MAGNUS_LIMIT_TYPE_NONE {
          //
          // get on-chip RSSI and add it to the string we display
          //
          let onChipRssi: Int32 = UgiRfMicron.getMagnusOnChipRssi(p)
          s.appendFormat("/%d", onChipRssi)
        }
        let cell = self.tagToCellMap[tag]
        if (cell != nil) {
          cell!.detail = s as String
        }
      }
    } else if self.specialFunction == SPECIAL_FUNCTION_READ_RF_MICRON_MAGNUS_TEMPERATURE {
      for p: UgiDetailedPerReadData in detailedPerReadData! {
        //
        // Get the temperature and add it to string we display
        //
        let temperatureC: Double = UgiRfMicron.getMagnusTemperature(tag, perReadData: p)
        let s = self.tagToDetailString[tag]!
        if s.length > 0 {
          s.appendString(" ")
        }
        if temperatureC == -999 {
          // invalid
          s.appendString("(invalid)")
        } else {
          s.appendFormat("%0.1f", temperatureC)
        }
        let cell = self.tagToCellMap[tag]
        if (cell != nil) {
          cell!.detail = s as String
        }
      }
    }
    
  }
  
  func inventoryDidStopWithResult(result: UgiInventoryCompletedReturnValues) {
    if (result != UgiInventoryCompletedReturnValues.UGI_INVENTORY_COMPLETED_LOST_CONNECTION) && (result != UgiInventoryCompletedReturnValues.UGI_INVENTORY_COMPLETED_OK) {
      UgiUiUtil.showInventoryError(result)
    }
    self.timer.invalidate()
    self.updateUI()
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.displayedTags.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell: UgiTagCell = self.tagTableView.dequeueReusableCellWithIdentifier("TagTableCell") as! UgiTagCell
    cell.accessoryType = .None
    cell.detail = nil
    let tag: UgiTag = self.displayedTags[indexPath.row]
    self.tagToCellMap[tag] = cell
    cell.displayTag = tag
    cell.themeColor = self.themeColor
    cell.title = tag.epc.toString()
    let s = self.tagToDetailString[tag]!
    if (s.length > 0) {
      cell.detail = s as String;
    } else if self.specialFunction == SPECIAL_FUNCTION_READ_USER_MEMORY {
      cell.detail = "user: \(UgiUtil.dataToString(tag.userMemory) ?? "")"
    } else if self.specialFunction == SPECIAL_FUNCTION_READ_TID_MEMORY {
      cell.detail = "tid: \(UgiUtil.dataToString(tag.tidMemory) ?? "")"
    }
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let tag: UgiTag = self.displayedTags[indexPath.row]
    self.tagTouched(tag)
  }
  ///////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////
  
  func tagTouched(tag: UgiTag) {
    let inventory: UgiInventory? = Ugi.singleton().activeInventory
    if inventory != nil {
      if !inventory!.isPaused {
        inventory!.pauseInventory()
      }
      UgiUiUtil.showMenuWithTitle(
        nil,
        withCancelCompletion: { 
          Ugi.singleton().activeInventory!.resumeInventory()
          self.updateUI()
        },
        withItems: [
          UgiMenuItem(title: "commission (write EPC)", withHandler: {
            self.doCommission(tag)
          }),
          UgiMenuItem(title: "read user memory", withHandler: {
            self.doReadUserMemory(tag)
          }),
          UgiMenuItem(title: "write user memory", withHandler: {
            self.self.doWriteUserMemory(tag)
          }),
          UgiMenuItem(title: "read then write user memory", withHandler: {
            self.self.doReadThenWriteUserMemory(tag)
          }),
          UgiMenuItem(title: "scan for this tag only", withHandler: {
            self.self.doLocate(tag)
          })
        ])
    }
    else {
      UgiUiUtil.showOk("not scanning", message: "Touch a tag while scanning (or paused) to act on the tag")
    }
  }
  // All tag actions called with inventory paused
  
  func doCommission(tag: UgiTag!) {
    UgiUiUtil.showTextInput(
      "commission tag",
      message: "EPC:",
      actionButtonTitle: "commission",
      initialText: tag.epc.toString(),
      allowAutoCorrection: false,
      keyboardType: .Default,
      switchText: nil,
      switchInitialValue: false,
      withCompletion: { (text, switchValue) in
        Ugi.singleton().activeInventory!.resumeInventory()
        self.updateUI()
        let newEpc: UgiEpc = UgiEpc(fromString: text)
        UgiUiUtil.showWaiting("commissioning")
        Ugi.singleton().activeInventory!.programTag(
          tag.epc,
          toEpc: newEpc,
          withPassword: UGI_NO_PASSWORD,
          whenCompleted: { (tag, result) in
            UgiUiUtil.hideWaiting()
            let message: String = (result == UgiTagAccessReturnValues.UGI_TAG_ACCESS_OK)
              ? "Successful\nNew EPC: \(tag!.epc.toString())"
              : UgiUiUtil.tagAccessErrorMessageForTagAccessReturnValue(result)!
            UgiUiUtil.showOk("commission tag", message: message)
        })
      },
      withCancelCompletion: {
        //
      }, withShouldEnableForTextCompletion: { (text: String?) -> Bool in
        if (text!.characters.count == 0) ||
           (text!.characters.count > tag.epc.toString().characters.count) {
          return false
        }
        let regex: NSRegularExpression = try! NSRegularExpression(pattern: "^[0-9a-fA-F]*$",
          options: [])
        return regex.numberOfMatchesInString(text!,
          options: [],
          range: NSMakeRange(0, text!.characters.count)) == 1
    })
  }
  
  func doReadUserMemory(tag: UgiTag) {
    Ugi.singleton().activeInventory!.resumeInventory()
    self.updateUI()
    UgiUiUtil.showWaiting("reading user memory")
    Ugi.singleton().activeInventory!.readTag(
      tag.epc,
      memoryBank: UgiMemoryBank.UGI_MEMORY_BANK_USER,
      offset: 0,
      minNumBytes: 16,
      maxNumBytes: 64,
      whenCompleted: {(tag, data, result) -> Void in
        UgiUiUtil.hideWaiting()
        if result == UgiTagAccessReturnValues.UGI_TAG_ACCESS_OK {
          let message: String = "Success\nUSER (\(UInt(data!.length)) bytes)\n\(UgiUtil.dataToString(data) ?? "")"
          UgiUiUtil.showOk("read user memory", message: message, okButtonTitle: "", withCompletion: nil)
        }
        else {
          UgiUiUtil.showOk(
            "read user memory",
            message: "Error: \(UgiUiUtil.tagAccessErrorMessageForTagAccessReturnValue(result)!)",
            okButtonTitle: "",
            withCompletion: nil)
        }
    })
  }
  
  func doWriteUserMemory(tag: UgiTag) {
    Ugi.singleton().activeInventory!.resumeInventory()
    self.updateUI()
    UgiUiUtil.showWaiting("writing user memory")
    let newData: NSData = "Hello World!".dataUsingEncoding(NSUTF8StringEncoding)!
    Ugi.singleton().activeInventory!.writeTag(
      tag.epc,
      memoryBank: UgiMemoryBank.UGI_MEMORY_BANK_USER,
      offset: 0,
      data: newData,
      previousData: nil,
      withPassword: UGI_NO_PASSWORD,
      whenCompleted: {(tag, result) -> Void in
        UgiUiUtil.hideWaiting()
        if result == UgiTagAccessReturnValues.UGI_TAG_ACCESS_OK {
          let message: String = "Success\nUSER (\(UInt(newData.length)) bytes)\n\(UgiUtil.dataToString(newData) ?? "")"
          UgiUiUtil.showOk("write user memory", message: message, okButtonTitle: "", withCompletion: nil)
        }
        else {
          UgiUiUtil.showOk(
            "write user memory",
            message: "Error: \(UgiUiUtil.tagAccessErrorMessageForTagAccessReturnValue(result)!)",
            okButtonTitle: "",
            withCompletion: nil)
        }
    })
  }
  
  func doReadThenWriteUserMemory(tag: UgiTag) {
    Ugi.singleton().activeInventory!.resumeInventory()
    self.updateUI()
    UgiUiUtil.showWaiting("reading user memory")
    Ugi.singleton().activeInventory!.readTag(
      tag.epc,
      memoryBank: UgiMemoryBank.UGI_MEMORY_BANK_USER,
      offset: 0,
      minNumBytes: 16,
      maxNumBytes: 64,
      whenCompleted: {(tag, data, result) -> Void in
        UgiUiUtil.hideWaiting()
        if result == UgiTagAccessReturnValues.UGI_TAG_ACCESS_OK {
          var buf: [UInt8] = [UInt8](count: data!.length, repeatedValue: 0)
          data!.getBytes(&buf, length: buf.count)
          let temp: UInt8 = buf[0]
          for i in 0..<data!.length-2 {
            buf[i] = buf[i+1]
          }
          buf[data!.length - 1] = temp
          let newData: NSData = NSData(bytes: buf, length: data!.length)
          UgiUiUtil.showWaiting("writing user memory")
          Ugi.singleton().activeInventory!.writeTag(
            tag!.epc,
            memoryBank: UgiMemoryBank.UGI_MEMORY_BANK_USER,
            offset: 0,
            data: newData,
            previousData: data,
            withPassword: UGI_NO_PASSWORD,
            whenCompleted: {(tag, result) -> Void in
              UgiUiUtil.hideWaiting()
              if result == UgiTagAccessReturnValues.UGI_TAG_ACCESS_OK {
                let message: String = "Success\nUSER (\(UInt(newData.length)) bytes)\n\(UgiUtil.dataToString(newData) ?? "")"
                UgiUiUtil.showOk("write user memory", message: message, okButtonTitle: "", withCompletion: nil)
              }
              else {
                UgiUiUtil.showOk(
                  "write user memory",
                  message: "Error writing user memory: \(UgiUiUtil.tagAccessErrorMessageForTagAccessReturnValue(result)!)",
                  okButtonTitle: "",
                  withCompletion: nil)
              }
          })
        }
        else {
          UgiUiUtil.showOk(
            "read user memory",
            message: "Error reading user memory: \(UgiUiUtil.tagAccessErrorMessageForTagAccessReturnValue(result)!)",
            okButtonTitle: "",
            withCompletion: nil)
        }
    })
  }
  
  func doLocate(tag: UgiTag) {
    self.timer.invalidate()
    UgiUiUtil.stopInventoryWithCompletionShowWaiting({() -> Void in
      self.displayedTags.removeAll()
      self.tagToCellMap.removeAll()
      self.tagToDetailString.removeAll()
      self.tagTableView.reloadData()
      let config: UgiRfidConfiguration = UgiRfidConfiguration.configWithInventoryType(UgiInventoryTypes.UGI_INVENTORY_TYPE_LOCATE_DISTANCE)
      config.selectMask = tag.epc.data
      config.selectOffset = 32
      config.selectBank = UgiMemoryBank.UGI_MEMORY_BANK_EPC
      Ugi.singleton().startInventory(self, withConfiguration: config, withEpc: tag.epc)
      self.updateUI()
      UgiUiUtil.showToast("Restarted inventory", message: "Searching only for \(tag.epc.toString)")
    })
  }
  ///////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////
  
  func doConfigure() {
    UgiUiUtil.showMenuWithTitle(
      "configure",
      withCancelCompletion: nil,
      withItems: [
        UgiMenuItem(title: "inventory type", withHandler: {
          var types: [String] = []
          for i in 0..<UgiRfidConfiguration.numInventoryTypes() {
            let ty:UgiInventoryTypes = UgiInventoryTypes(rawValue: Int32(i+1))!
            types.append(UgiRfidConfiguration.nameForInventoryType(ty))
          }
          UgiUiUtil.showChoices(
            types,
            withInitialSelectedIndex: Int32(self.inventoryType.rawValue) - 1,
            withTitle: "inventory type",
            withMessage: nil,
            withActionButtonTitle: "set type",
            withCanCancel: true,
            withCompletion: { (index, regionName) in
              self.inventoryType = UgiInventoryTypes(rawValue: index + 1)!
            },
            withConfirmationCompletion: nil,
            withCancelCompletion: nil)
        }),
        UgiMenuItem(title: "special functions", withHandler: {
          UgiUiUtil.showChoices(
            ["none", "read User Memory", "read TID memory", "read RF Micron sensor code", "read RF Micron temperature"],
            withInitialSelectedIndex: Int32(self.specialFunction),
            withTitle: "special function",
            withMessage: nil,
            withActionButtonTitle: "set",
            withCanCancel: true,
            withCompletion: { (index, regionName) in
              self.specialFunction = Int(index)
            },
            withConfirmationCompletion: nil,
            withCancelCompletion: nil)
        })
      ])
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////
  
  @IBAction func doActions(sender: AnyObject) {
    UgiUiUtil.showMenuWithTitle(
      "choose action",
      withCancelCompletion: nil,
      withItems: [
        UgiMenuItem(title: "set region", withHandler: {
          Ugi.singleton().invokeSetRegion()
        }),
        UgiMenuItem(title: "example: second page", withHandler: {
          self.performSegueWithIdentifier("secondPageSegue", sender: self)
        })
      ])
  }


}
