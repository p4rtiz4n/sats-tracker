//
// Created by p4rtiz4n on 23/12/2020.
//

import Foundation

enum AssetsViewModel {

    case loading
    case partialLoad(_ sections: [Section])
    case loaded(_ sections: [Section])
    case failedToLoad(_ error: Error)
}

extension AssetsViewModel {

    struct Section {
        let title: String
        let assets: [Asset]
    }

    struct Asset {
        let id: String
        let rank: Int
        let symbol: String
        let name: String
        let imageURL: URL
        let price: String
        let priceDirection: Direction
        let pricePctChange: String
        let candlesViewModel: CandlesViewModel

        enum Direction: String {
            case up = "▲"
            case down = "▼"
            case unknown = "_"
        }
    }
}

// MARK: - Utilities

extension  AssetsViewModel {

    func asset(at idxPath: IndexPath) -> Asset? {
        switch self {
        case let .loaded(sections), let .partialLoad(sections):
            return sections[safe: idxPath.section]?.assets[safe: idxPath.item]
        default:
            return nil
        }
    }

    func sections() -> [AssetsViewModel.Section] {
        switch self {
        case let .loaded(sections), let .partialLoad(sections):
            return sections
        default:
            return []
        }
    }

    func sectionsCount() -> Int {
        sections().count
    }
}

// MARK: - Convenience initializer

extension AssetsViewModel.Asset {

    init(asset: Asset, candles: CandlesViewModel) {
        id = asset.id
        rank = asset.rank
        symbol = asset.symbol
        name = asset.name
        imageURL = Constant.imageURL(asset.symbol)
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
    
    static func currencyFormatter(for price: Double?) -> NumberFormatter {
        guard (price ?? 0) > 10  else {
            return ServiceDirectory.Formatter.currencyFractional
        }
        return ServiceDirectory.Formatter.currencyNonFractional
    }
}

// MARK: - Constants

private extension AssetsViewModel.Asset {

    enum Constant {

        static func imageURL(_ symbol: String) -> URL {
            let id = symbol.lowercased()
            return URL(
                string: "https://static.coincap.io/assets/icons/\(id)@2x.png"
            )!
        }
    }
}