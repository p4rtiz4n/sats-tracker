//
// Created by p4rtiz4n on 08/03/2021.
//

import Foundation

protocol WidgetsService {
    
    typealias AssetCandleHandler = (Result<([Asset], [Candle]), Error>) -> ()
    typealias AssetHandler = (Result<[Asset], Error>) -> ()

    func fetchAssetsAndCandles(
        for options: [AssetOption],
        handler: @escaping AssetCandleHandler
    )

    func fetchAssets(_ handler: @escaping AssetHandler)
    func defaultAssets() -> [Asset]
}

// MARK: - DefaultWidgetsService

class DefaultWidgetsService {

    private let assetsService: AssetsService
    private let candleCacheService: CandlesCacheService

    init(
        assetsService: AssetsService,
        candleCacheService: CandlesCacheService
    ) {
        self.assetsService = assetsService
        self.candleCacheService = candleCacheService
    }
}

// MARK: - WidgetsService

extension DefaultWidgetsService: WidgetsService {

    func fetchAssetsAndCandles(
        for options: [AssetOption],
        handler: @escaping AssetCandleHandler
    ) {
        // TODO: - Implement
    }

    func fetchAssets(_ handler: @escaping AssetHandler) {
        // TODO: - Implement
    }

    func defaultAssets() -> [Asset] {
        // TODO: - Implement
        return []
    }
}
