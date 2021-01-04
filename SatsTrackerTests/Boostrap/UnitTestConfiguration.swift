//
// Created by p4rtiz4n on 25/12/2020.
//

import UIKit
@testable import SatsTracker

class UnitTestConfiguration: Configuration {
    
    func bootstrap(_ window: UIWindow?) {
        ServiceDirectory.network = DefaultNetwork()
        ServiceDirectory.assetsService = DefaultAssetsService(
            network: ServiceDirectory.network
        )
        ServiceDirectory.favouriteAssetsService = DefaultFavoriteAssetsService()
        ServiceDirectory.Cache.candle = DefaultCandlesCacheService(
            assetsService: ServiceDirectory.assetsService
        )
        ServiceDirectory.Navigation.rootWireframeFactory = DefaultAssetsWireframeFactory(
            window: window,
            assetsService: ServiceDirectory.assetsService,
            candleCacheService: ServiceDirectory.Cache.candle,
            favoriteAssetsService: ServiceDirectory.favouriteAssetsService,
            assetDetailWireframeFactory: DefaultAssetDetailWireframeFactory(
                candleCacheService: DefaultCandlesCacheService(
                    assetsService: ServiceDirectory.assetsService
                ),
                favoriteAssetsService: ServiceDirectory.favouriteAssetsService
            )
        )
        ServiceDirectory.Cache.image = DefaultImageCache()
    }
}
