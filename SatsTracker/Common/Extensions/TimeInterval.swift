//
// Created by p4rtiz4n on 30/12/2020.
//

import Foundation

extension TimeInterval {
    
    var milli: Int {
        Int(self * 1000)
    }

    static func days(_ cnt: Int) -> TimeInterval {
        86400 * TimeInterval(cnt)
    }
}
