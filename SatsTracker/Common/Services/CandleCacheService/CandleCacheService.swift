//
// Created by p4rtiz4n on 28/12/2020.
//

import Foundation

protocol CandlesCacheService {

    typealias Handler = (Result<[Candle], Error>) -> ()

    func candles(
        assetId: String,
        interval: Interval,
        start: Date?,
        end: Date?,
        handler: @escaping Handler
    )
    func candles(assetId: String, handler: @escaping Handler)
    func cancel(_ assetId: String?, _ idHash: Int?)
    func clear()
}

class DefaultCandlesCacheService: CandlesCacheService {

    private let assetsService: AssetsService
    private let downloadQueue: OperationQueue
    private var cache: [String: [Candle]] = [:]

    init(assetsService: AssetsService) {
        self.assetsService = assetsService
        self.downloadQueue = OperationQueue()
        self.downloadQueue.name = "CandleCache Queue"
        self.downloadQueue.maxConcurrentOperationCount = 20
    }

    func candles(assetId: String, handler: @escaping Handler) {
        candles(
            assetId: assetId,
            interval: .d1,
            start: nil,
            end: nil,
            handler: handler
        )
    }

    func candles(
        assetId: String,
        interval: Interval,
        start: Date?,
        end: Date?,
        handler: @escaping Handler
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let candles = self?.cachedCandles(for: assetId) {
                handler(.success(candles))
                return
            }

            self?.downloadCandles(
                for: assetId,
                interval: interval,
                start: start,
                end: end
            ) { result in
                switch result {
                case let .success(candles):
                    self?.cache(candles, assetId: assetId)
                    handler(.success(candles))
                case let .failure(err):
                    handler(.failure(err))
                }
            }
        }
    }

    func cancel(_ assetId: String?, _ idHash: Int?) {
        guard let id = assetId?.sdbmhash ?? idHash else {
            return
        }
        downloadQueue.operations
            .first(where: { ($0 as? CandlesDownloadOperation)?.assetIdHash == id })?
            .cancel()
    }

    func clear() {
        downloadQueue.cancelAllOperations()
        cache = [:]
    }

    private func downloadCandles(
        for assetId: String,
        interval: Interval,
        start: Date?,
        end: Date?,
        handler: @escaping CandlesCacheService.Handler
    ) {
        let op = CandlesDownloadOperation(
            assetId: assetId,
            interval: interval,
            start: start,
            end: end,
            assetsService: assetsService
        )

        op.completionBlock = { [weak op] in
            guard (op?.isCancelled ?? false) == false else {
                return
            }
            guard let result = op?.result else {
                handler(.failure(CandleCacheError.unknownOperationError))
                return
            }
            handler(result)
        }
        downloadQueue.addOperation(op)
    }

    private func cachedCandles(for assetId: String) -> [Candle]? {
        return cache[assetId]
    }

    private func cache(_ candles: [Candle], assetId: String) {
        cache[assetId] = candles
    }
}

// MARK: - CandlesDownloadOperation

private final class CandlesDownloadOperation: AsyncOperation {

    typealias CandlesHandler = (Result<[Candle], Error>) -> ()

    let assetIdHash: Int
    let assetId: String
    let interval: Interval
    let start: Date?
    let end: Date?

    private let assetsService: AssetsService

    var result: Result<[Candle], Error>? = nil

    init(
        assetId: String,
        interval: Interval,
        start: Date? = nil,
        end: Date? = nil,
        assetsService: AssetsService
    ) {
        self.assetId = assetId
        self.assetIdHash = assetId.sdbmhash
        self.assetsService = assetsService
        self.interval = interval
        self.start = start
        self.end = end
    }

    override func asyncStart() {
        guard !isCancelled else {
            asyncFinish()
            return
        }

        candles(for: assetId) { [weak self] result in
            guard !(self?.isCancelled ?? false) else {
                self?.asyncFinish()
                return
            }

            self?.result = result
            self?.asyncFinish()
        }
    }

    private func candles(for assetId: String, handler: @escaping CandlesHandler) {
        assetsService.markets(for: assetId) { [weak self] result in
            guard !(self?.isCancelled ?? false) else {
                self?.asyncFinish()
                return
            }
            switch result {
            case let .success(markets):
                self?.candles(from: markets, handler: handler)
            case let .failure(error):
                handler(.failure(error))
            }
        }
    }

    private func candles(from markets: [Market], handler: @escaping CandlesHandler) {
        let usdMarkets = self.usdMarkets(from: markets)
        guard let market = usdMarkets.first ?? markets.first else {
            handler(.failure(AssetsInteractorError.selectedQuoteMarketNotFound))
            return
        }

        guard !isCancelled else {
            asyncFinish()
            return
        }

        guard !Constant.unavailableBaseIds.contains(market.baseId) else {
            handler(.failure(CandleCacheError.unavailable))
            return
        }

        let expectedCnt = units(interval, start: start, end: end) - 2

        assetsService.candles(
            exchange: market.exchangeId,
            base: market.baseId,
            quote: market.quoteId,
            interval: interval,
            start: start,
            end: end,
            handler: { [weak self] result in
                switch result {
                case let .success(candles):
                    if candles.count < expectedCnt && markets.count > 1 {
                        let tryMarkets = markets.filter {
                            $0 != market
                        }
                        self?.candles(from: tryMarkets, handler: handler)
                        return
                    }
                    if candles.count == 0 {
                        handler(.failure(CandleCacheError.unavailable))
                        return
                    }
                    handler(.success(candles))
                case let .failure(err):
                    if markets.count > 1 {
                        let tryMarkets = markets.filter {
                            $0 != market
                        }
                        self?.candles(from: tryMarkets, handler: handler)
                        return
                    }
                    handler(.failure(err))
                }
            }
        )
    }

    private func usdMarkets(from markets: [Market]) -> [Market] {
        return markets.filter { Constant.quoteSymbols.contains($0.quoteSymbol) }
            .sorted { ($0.volumeUsd24Hr ?? 0) > ($1.volumeUsd24Hr ?? 0) }
    }

    private func units(_ intv: Interval, start: Date?, end: Date?) -> Int {
        guard let start = start, let end = end else {
            return 0
        }

        switch interval {
        case .d1:
            return Int(ceil(start.distance(to: end) / TimeInterval.days(1)))
        // TODO: Implement another time frames
        default:
            return 0
        }
    }
}

// MARK: - Constants

private extension CandlesDownloadOperation {

    enum Constant {
        static let quoteSymbols = ["USD", "USDT", "USDC", "BUSD", "DAI"]
        static let unavailableBaseIds = ["polkadot"]
    }
}

// MARK: - Error

enum CandleCacheError: Error {
    case failedToLoadData
    case unavailable
    case unknownOperationError
}
