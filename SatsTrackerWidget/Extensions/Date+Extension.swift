//
// Created by p4rtiz4n on 14/03/2021.
//

import Foundation

extension Date {
    
    func adding(minutes: Double) -> Date {
        return addingTimeInterval(60 * minutes)
    }
}
