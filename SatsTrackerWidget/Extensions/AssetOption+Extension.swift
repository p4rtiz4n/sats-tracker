//
// Created by p4rtiz4n on 08/03/2021.
//

import Foundation

extension AssetOption {

    convenience init(asset: Asset) {
        self.init(identifier: asset.id, display: asset.name)
    }
}
