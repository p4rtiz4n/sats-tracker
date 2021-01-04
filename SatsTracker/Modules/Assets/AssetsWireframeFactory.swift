//
// Created by p4rtiz4n on 23/12/2020.
//

import UIKit

protocol AssetsWireframeFactory {

    func makeWireframe() -> AssetsWireframe
}

// MARK: - DefaultAssetsWireframeFactory

class DefaultAssetsWireframeFactory {

    private let assetsService: AssetsService
    private let candleCacheService: CandlesCacheService
    private let favoriteAssetsService: FavouriteAssetsService
    private let assetDetailWireframeFactory: AssetDetailWireframeFactory

    private weak var window: UIWindow?

    init(
        window: UIWindow?,
        assetsService: AssetsService,
        candleCacheService: CandlesCacheService,
        favoriteAssetsService: FavouriteAssetsService,
        assetDetailWireframeFactory: AssetDetailWireframeFactory
    ) {
        self.window = window
        self.assetsService = assetsService
        self.candleCacheService = candleCacheService
        self.favoriteAssetsService = favoriteAssetsService
        self.assetDetailWireframeFactory = assetDetailWireframeFactory
    }
}

// MARK: - AssetsWireframeFactory

extension DefaultAssetsWireframeFactory: AssetsWireframeFactory {

    func makeWireframe() -> AssetsWireframe {
        return DefaultAssetsWireframe(
            interactor: DefaultAssetsInteractor(
                assetsService: assetsService,
                candleCacheService: candleCacheService,
                favoriteAssetsService: favoriteAssetsService
            ),
            assetDetailWireframeFactory: assetDetailWireframeFactory,
            window: window
        )
    }
}
