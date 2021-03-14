//
// Created by p4rtiz4n on 14/03/2021.
//

import Foundation

extension Array {
    
    func last(n: Int) -> Array {
        guard count > n else {
            return self
        }
        return Array(self[count - n..<count])
    }

    func first(n: Int) -> Array {
        guard count > n else {
            return self
        }
        return Array(self[0..<n])
    }
 }
