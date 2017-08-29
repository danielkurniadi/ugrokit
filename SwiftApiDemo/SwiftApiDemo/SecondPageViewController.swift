//
//  SecondPageViewController.h
//  ApiDemo
//
//  Created by Tony Requist on 3/9/16.
//  Copyright © 2016 U Grok It. All rights reserved.
//
import UIKit
class SecondPageViewController: UgiViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.themeColor = UIColor(fromHexString: "F58026")
    self.titleView!.setRightButtonImage(
      UIImage(named: "btn_second_page_right.png"),
      withColor: nil,
      withHighlightedImage: nil,
      withHighlightedColor: nil,
      withCompletion: {
        Ugi.log("right button touched")
    })
    self.footer.setCenterText("back", withCompletion: {() -> Void in
      self.goBack()
    })
    self.footer.setLeftText("info", withCompletion: {() -> Void in
      UgiUiUtil.showVersionAlertWithTitle(nil, withShowExtraInfo: false)
    })
  }
  
  @IBOutlet var footer: UgiFooterView!
}
