//
// Created by p4rtiz4n on 02/01/2021.
//

import Foundation

enum AssetDetailViewModel {

    case loading(_ asset: Asset)
    case loaded(_ asset: Asset)
    case failed(_ asset: Asset)
}

extension AssetDetailViewModel {

    struct Asset {
        let id: String
        let rank: Int
        let symbol: String
        let name: String
        let imageURL: URL
        let price: String
        let priceDirection: Direction
        let pricePctChange: String
        let marketCapUsd: String
        let volumeUsd24Hr: String
        let vwap24Hr: String
        let supply: String
        let maxSupply: String
        let candlesViewModel: CandlesViewModel
        let isFavourite: Bool

        enum Direction: String {
            case up = "▲"
            case down = "▼"
            case unknown = "_"
        }
    }
}

// MARK: - Convenience initializer

extension AssetDetailViewModel.Asset {

    init(_ asset: Asset, fav: Bool, candles: CandlesViewModel) {

        func formatted(_ num: Double?, fallback: String = "-") -> String {
            return num != nil ? Int(num!).abbreviated : fallback
        }

        id = asset.id
        rank = asset.rank
        symbol = asset.symbol
        name = asset.name
        imageURL = Constant.imageURL(asset.symbol)
        isFavourite = fav
        marketCapUsd = formatted(asset.marketCapUsd)
        volumeUsd24Hr = formatted(asset.volumeUsd24Hr)
        vwap24Hr = formatted(asset.vwap24Hr)
        supply = formatted(asset.supply)
        maxSupply = formatted(asset.maxSupply)
        candlesViewModel = candles

        price = AssetsViewModel.Asset.currencyFormatter(for: asset.priceUsd)
            .string(for: asset.priceUsd) ?? "-"

        if let pctChange = asset.changePercent24Hr {
            priceDirection = pctChange >= 0 ? .up : .down
            pricePctChange = ServiceDirectory.Formatter.percentage
                .string(for: pctChange / 100) ?? ""
        } else {
            priceDirection = .unknown
            pricePctChange = "-"
        }
    }

}

// MARK: - Utilities

extension AssetDetailViewModel {

    func asset() -> AssetDetailViewModel.Asset {
        switch self {
        case let .loaded(asset), let .loading(asset), let .failed(asset):
            return asset
        }
    }
}

// MARK: - Constants

private extension AssetDetailViewModel.Asset {

    enum Constant {

        static func imageURL(_ symbol: String) -> URL {
            let id = symbol.lowercased()
            return URL(
                string: "https://static.coincap.io/assets/icons/\(id)@2x.png"
            )!
        }
    }
}