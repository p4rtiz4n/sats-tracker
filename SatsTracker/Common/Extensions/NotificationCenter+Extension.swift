//
// Created by p4rtiz4n on 31/12/2020.
//

import Foundation

extension NotificationCenter {

    func addObserver(_ observer: Any, sel: Selector, name: NSNotification.Name) {
        addObserver(observer, selector: sel, name: name, object: nil)
    }
}