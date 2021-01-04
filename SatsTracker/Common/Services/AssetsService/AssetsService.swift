//
// Created by p4rtiz4n on 28/12/2020.
//

import Foundation

protocol AssetsService {

    typealias AssetsPageHandler = ([Asset])->()
    typealias AssetsHandler = (Result<[Asset], Error>)->()
    typealias MarketsHandler = (Result<[Market], Error>)->()
    typealias CandlesHandler = (Result<[Candle], Error>)->()

    func assets(
        pageHandler: @escaping AssetsPageHandler,
        completionHandler: @escaping AssetsHandler
    )

    func markets(for assetId: String, handler: @escaping MarketsHandler)

    func candles(
        exchange: String,
        base: String,
        quote: String,
        interval: Interval,
        start: Date?,
        end: Date?,
        handler: @escaping CandlesHandler
    )
}

// MARK: - DefaultAssetsService

class DefaultAssetsService: AssetsService {

    private let network: Network

    init(network: Network) {
        self.network = network
    }

    func assets(
        pageHandler: @escaping AssetsPageHandler,
        completionHandler: @escaping AssetsHandler
    ) {
        loadPage(
            0,
            latestAssets: [],
            pageHandler: pageHandler,
            completionHandler: completionHandler
        )
    }

    func markets(for assetId: String, handler: @escaping MarketsHandler){
        network.request(
            API.markets(assetId: assetId),
            handler: { (result: Result<DataResponse<Market>, Error>) in
                switch result {
                case let .success(resp):
                    handler(.success(resp.data))
                case let .failure(err):
                    handler(.failure(err))
                }
            }
        )
    }

    func candles(
        exchange: String,
        base: String,
        quote: String,
        interval: Interval,
        start: Date?,
        end: Date?,
        handler: @escaping CandlesHandler
    ) {
        network.request(
            API.candles(
                exchange: exchange,
                base: base,
                quote: quote,
                interval: interval,
                start: start,
                end: end
            ),
            handler: { (result: Result<DataResponse<Candle>, Error>) in
                switch result {
                case let .success(resp):
                    handler(.success(resp.data))
                case let .failure(err):
                    handler(.failure(err))
                }
            }
        )
    }

    private func loadPage(
        _ idx: Int,
        latestAssets: [Asset],
        pageHandler: @escaping AssetsPageHandler,
        completionHandler: @escaping AssetsHandler
    ) {
        network.request(
            API.assets(lim: Constant.pageSize, offset: idx * Constant.pageSize),
            handler: { [weak self] (result: Result<DataResponse<Asset>, Error>) in
                switch result {
                case let .success(resp):
                    guard resp.data.count > 0 else {
                        completionHandler(.success(latestAssets))
                        return
                    }
                    let assets = latestAssets + resp.data
                    pageHandler(assets)
                    self?.loadPage(
                        idx + 1 ,
                        latestAssets: assets,
                        pageHandler: pageHandler,
                        completionHandler: completionHandler
                    )
                case let .failure(err):
                    completionHandler(.failure(err))
                }
            }
        )
    }
}

// MARK: - API

private extension DefaultAssetsService {

    enum API: NetworkEndPoint {

        case assets(lim: Int, offset: Int)
        case markets(assetId: String)
        case candles(
            exchange: String,
            base: String,
            quote: String,
            interval: Interval,
            start: Date?,
            end: Date?
        )

        var url: URL {
            switch self {
            case .assets:
                return Constant.baseURL.appendingPathComponent("assets")
            case .candles:
                return Constant.baseURL.appendingPathComponent("candles")
            case .markets:
                return Constant.baseURL.appendingPathComponent("markets")
            }
        }

        var queryItems: Dictionary<String, String>? {
            switch self {
            case let .assets(lim, offset):
                return [
                    "limit": "\(lim)",
                    "offset": "\(offset)"
                ]
            case let .markets(assetId):
                return [
                    "baseId": "\(assetId)",
                    "limit": "\(Constant.pageSize)"
                ]
            case let .candles(exchange, base, quote, interval, start, end):
                var params = [
                    "exchange": exchange,
                    "baseId": base,
                    "quoteId": quote,
                    "interval": interval.rawValue
                ]
                if let start = start {
                    params["start"] = "\(start.timeIntervalSince1970.milli)"
                }
                if let end = end {
                    params["end"] = "\(end.timeIntervalSince1970.milli)"
                }
                return params

            }
        }
    }
}

// MARK: - DefaultAssetsService

private extension DefaultAssetsService {

    enum Constant {
        static let pageSize: Int = 2000
        static let baseURL = URL(string: "http://api.coincap.io/v2")!
    }
}
