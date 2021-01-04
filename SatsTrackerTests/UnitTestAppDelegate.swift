//
// Created by p4rtiz4n on 25/12/2020.
//

import Foundation
@testable import SatsTracker

@objc(UnitTestAppDelegate)
class UnitTestAppDelegate: AppDelegate {
    
    override func setupConfiguration() {
        UnitTestConfiguration().bootstrap(self.window)
    }
}
