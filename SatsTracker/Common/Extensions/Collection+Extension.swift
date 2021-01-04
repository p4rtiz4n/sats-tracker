//
// Created by p4rtiz4n on 30/12/2020.
//

import Foundation

extension Collection {

    /// Returns the element at the specified index if within bounds, or nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}