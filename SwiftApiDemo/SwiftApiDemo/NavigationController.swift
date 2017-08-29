//
//  NavigationController.h
//  UGrokIt
//
//  Created by Anthony Requist on 1/22/13.
//  Copyright (c) 2013 Anthony Requist. All rights reserved.
//
import UIKit
class NavigationController: UINavigationController, UgiUiDelegate {

  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    if self.viewControllers.count > 0 {
      let vc: UIViewController = self.viewControllers[self.viewControllers.count - 1]
      return vc.supportedInterfaceOrientations()
    }
    return Ugi.singleton().supportedInterfaceOrientationsWithAllowRotationOnTablet(true)
  }
}
