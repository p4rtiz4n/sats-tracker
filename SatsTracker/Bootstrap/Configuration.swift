//
// Created by p4rtiz4n on 25/12/2020.
//

import UIKit

protocol Configuration {
    
    func bootstrap(_ window: UIWindow?)
}

class DefaultConfiguration: Configuration {
    
    func bootstrap(_ window: UIWindow?) {
        ServiceDirectory.network = DefaultNetwork()
        ServiceDirectory.favouriteAssetsService = DefaultFavoriteAssetsService()
        ServiceDirectory.assetsService = DefaultAssetsService(
            network: ServiceDirectory.network
        )

        ServiceDirectory.Cache.image = DefaultImageCache()
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
    }
}
