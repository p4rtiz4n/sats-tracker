//
// Created by p4rtiz4n on 23/12/2020.
//

import UIKit

protocol AssetDetailWireframeFactory {

    func makeWireframe(_ asset: Asset, container: UIViewController?) -> AssetDetailWireframe
}

// MARK: - DefaultAssetDetailWireframeFactory

class DefaultAssetDetailWireframeFactory {

    private let candleCacheService: CandlesCacheService
    private let favoriteAssetsService: FavouriteAssetsService

    init(
        candleCacheService: CandlesCacheService,
        favoriteAssetsService: FavouriteAssetsService
    ) {
        self.candleCacheService = candleCacheService
        self.favoriteAssetsService = favoriteAssetsService
    }
}

// MARK: - AssetDetailWireframeFactory

extension DefaultAssetDetailWireframeFactory: AssetDetailWireframeFactory {

    func makeWireframe(_ asset: Asset, container: UIViewController?) -> AssetDetailWireframe {
        return DefaultAssetDetailWireframe(
            interactor: DefaultAssetDetailInteractor(
                candleCacheService: candleCacheService,
                favoriteAssetsService: favoriteAssetsService
            ),
            asset: asset,
            container: container
        )
    }
}
