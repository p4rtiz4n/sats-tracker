//
// Created by p4rtiz4n on 02/01/2021.
//

import Foundation

protocol AssetDetailInteractor {

    typealias CandlesHandler = (Result<[Candle], Error>)->()

    func candles(for asset: Asset, lim: Int?, handler: @escaping CandlesHandler)

    func favoriteAssets() -> [FavouriteAsset]
    func toggleFavourite(_ asset: Asset)
}

class DefaultAssetDetailInteractor {

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

// MARK: - AssetDetailInteractor

extension DefaultAssetDetailInteractor: AssetDetailInteractor {

    func candles(for asset: Asset, lim: Int?, handler: @escaping CandlesHandler) {
        var (start, end): (Date?, Date?) = (nil, nil)
        if let lim = lim {
            start = Date().addingTimeInterval(-TimeInterval.days(lim))
            end = Date()
        }
        candleCacheService.candles(
            assetId: asset.id,
            interval: .d1,
            start: start,
            end: end,
            handler: handler
        )
    }

    func favoriteAssets() -> [FavouriteAsset] {
        favoriteAssetsService.favouriteAssets()
    }

    func toggleFavourite(_ asset: Asset) {
        guard let fav = favoriteAssets().first(where: { $0.id == asset.id}) else {
            favoriteAssetsService.addToFavorite(FavouriteAsset(asset: asset))
            return
        }
        favoriteAssetsService.removerFromFavorite(fav)
    }
}
