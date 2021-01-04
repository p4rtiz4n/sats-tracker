//
// Created by p4rtiz4n on 25/12/2020.
//

import Foundation
@testable import SatsTracker

@objc(UITestAppDelegate)
class UITestAppDelegate: AppDelegate {
    
    override func setupConfiguration() {
        UITestConfiguration().bootstrap(self.window)
    }
}
