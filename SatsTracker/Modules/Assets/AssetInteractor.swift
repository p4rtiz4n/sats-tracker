//
// Created by p4rtiz4n on 20/12/2020.
//

import Foundation

protocol AssetsInteractor {

    typealias AssetsPageHandler = ([Asset])->()
    typealias AssetsHandler = (Result<[Asset], Error>)->()
    typealias CandlesHandler = (Result<[Candle], Error>)->()

    func load(
        pageLoadedHandler: @escaping AssetsPageHandler,
        completionHandler: @escaping AssetsHandler
    )

    func candles(for asset: Asset, lim: Int?, handler: @escaping CandlesHandler)
    func candlesCancel(_ assetId: String?, _ idHash: Int?)
    func candlesClearCache()

    func favoriteAssets() -> [FavouriteAsset]
    func toggleFavourite(_ asset: Asset)
}

// MARK: - DefaultAssetsService

class DefaultAssetsInteractor: AssetsInteractor {

    private let assetsService: AssetsService
    private let candleCacheService: CandlesCacheService
    private let favoriteAssetsService: FavouriteAssetsService

    init(
        assetsService: AssetsService,
        candleCacheService: CandlesCacheService,
        favoriteAssetsService: FavouriteAssetsService
    ) {
        self.assetsService = assetsService
        self.candleCacheService = candleCacheService
        self.favoriteAssetsService = favoriteAssetsService
    }

    // MARK: - Asset handling

    func load(
        pageLoadedHandler: @escaping ([Asset]) -> (),
        completionHandler: @escaping (Result<[Asset], Error>) -> ()
    ) {
        assetsService.assets(
            pageHandler: pageLoadedHandler,
            completionHandler: completionHandler
        )
    }

    // MARK: - Candles handling

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

    func candlesCancel(_ assetId: String?, _ idHash: Int?) {
        candleCacheService.cancel(assetId, idHash)
    }

    func candlesClearCache() {
        candleCacheService.clear()
    }

    // MARK: - Favourite handling

    func favoriteAssets() -> [FavouriteAsset] {
        favoriteAssetsService.favoriteAssets()
    }

    func toggleFavourite(_ asset: Asset) {
        guard let fav = favoriteAssets().first(where: { $0.id == asset.id}) else {
            favoriteAssetsService.addToFavorite(FavouriteAsset(asset: asset))
            return
        }
        favoriteAssetsService.removerFromFavorite(fav)
    }
}

// MARK: - AssetsServiceError

enum AssetsInteractorError: Error {
    case network
    case selectedQuoteMarketNotFound
}
