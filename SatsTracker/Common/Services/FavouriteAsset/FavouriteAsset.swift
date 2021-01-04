//
// Created by p4rtiz4n on 01/01/2021.
//

import Foundation

struct FavouriteAsset: Equatable, Codable {
    let id: String
    let name: String
    let symbol: String
}

// MARK: Convenience initializer

extension FavouriteAsset {

    init(asset: Asset) {
        id = asset.id
        name = asset.name
        symbol = asset.symbol
    }
}
