//
// Created by p4rtiz4n on 20/12/2020.
//

import UIKit

autoreleasepool {
    
    _ = UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(
        to: UnsafeMutablePointer<Int8>.self,
        capacity: Int(CommandLine.argc)
    )

    let delegateClass: AnyClass
    
    if let unitTestClass = NSClassFromString("UnitTestAppDelegate") {
        delegateClass = unitTestClass
    } else if let uiTestClass = NSClassFromString("UITestAppDelegate") {
        delegateClass = uiTestClass
    } else {
        delegateClass = AppDelegate.self
    }
    
    UIApplicationMain(
        CommandLine.argc,
        CommandLine.unsafeArgv,
        nil,
        NSStringFromClass(delegateClass)
    )
}


