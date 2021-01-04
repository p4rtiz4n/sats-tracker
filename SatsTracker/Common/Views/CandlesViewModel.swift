//
// Created by p4rtiz4n on 28/12/2020.
//

import UIKit

enum CandlesViewModel {

    struct Candle {
        let open: CGFloat
        let high: CGFloat
        let low: CGFloat
        let close: CGFloat
        let volume: CGFloat
        let period: Date
    }

    case unavailable(_ cnt: Int)
    case loading(_ cnt: Int)
    case loaded(_ candles: [Candle])
}

// MARK: - Candle

extension CandlesViewModel.Candle {

    init(_ candle: Candle) {
        open = CGFloat(candle.open)
        high = CGFloat(candle.high)
        low = CGFloat(candle.low)
        close = CGFloat(candle.close)
        volume = CGFloat(candle.volume)
        period = candle.period
    }
}

// MARK: - Utilities

extension CandlesViewModel {

    func isLoading() -> Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }
}