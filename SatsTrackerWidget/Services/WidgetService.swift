//
// Created by p4rtiz4n on 08/03/2021.
//

import Foundation

protocol WidgetsService {

    typealias AssetCandleHandler = (Result<([Asset], [String: [Candle]]), Error>) -> ()
    typealias AssetHandler = (Result<[Asset], Error>) -> ()

    func fetchAssetsAndCandles(
        for options: [AssetOption],
        handler: @escaping AssetCandleHandler
    )

    func fetchAssets(handler: @escaping AssetHandler)
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
        assetsService.assets(
            pageHandler: { _ in () },
            completionHandler: { [weak self] result in
                switch result {
                case let .success(allAssets):
                    let selectedIds = options.map { $0.identifier }
                    let assets = allAssets.filter { selectedIds.contains($0.id) }
                    self?.fetchCandles(for: assets, handler: handler)
                case let .failure(error):
                    handler(.failure(error))
                }
            })
    }

    func fetchCandles(for assets: [Asset], handler: @escaping AssetCandleHandler) {
        candleCacheService.clear()
        let group = DispatchGroup()
        var info: [String: [Candle]] = [:]
        for asset in assets {
            group.enter()
            candleCacheService.candles(
                assetId: asset.id,
                handler: { result in
                    switch result {
                    case let .success(candles):
                        info[asset.id] = candles
                    case let .failure(error):
                        print(error)
                    }
                    group.leave()
                }
            )
        }
        group.notify(queue: DispatchQueue.global()) {
            handler(.success((assets, info)))
        }
    }

    func fetchAssets(handler: @escaping AssetHandler) {
        assetsService.assets(
            pageHandler: { _ in () },
            completionHandler: handler
        )
    }

    func defaultAssets() -> [Asset] {
        return [
            .init(
                id: "bitcoin",
                rank: 1,
                symbol: "BTC",
                name: "Bitcoin"
            ),
            .init(
                id: "ethereum",
                rank: 2,
                symbol: "ETH",
                name: "Ethereum"
            ),
            .init(
                id: "monero",
                rank: 22,
                symbol: "XMR",
                name: "Monero"
            ),
            .init(
                id: "uniswap",
                rank: 8,
                symbol: "UNI",
                name: "Uniswap"
            ),
        ]
    }
}
