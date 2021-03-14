//
// Created by p4rtiz4n on 14/03/2021.
//

import SwiftUI
import UIKit

struct ChartViewModel {

    let candles: [Candle]

    func candleViewModels(in size: CGSize) -> [CandleViewModel] {
        var viewModels: [CandleViewModel] = []
        guard size.width > 0, size.height > 0, candles.count > 0 else {
            return []
        }

        let candles = self.candles.last(n: 30)
        let width = size.width / CGFloat(candles.count)
        let high = candles.sorted { $0.high > $1.high }.first?.high ?? 1
        let low = candles.sorted { $0.low < $1.low }.first?.low ?? 0
        let yLength = CGFloat(high - low)
        let yRatio = size.height / yLength

        for i in 0..<candles.count {
            let candle = candles[i]
            let (close, open) = (candle.close, candle.open)
            let isGreen = candle.close >= candle.open
            let bodyHigh = isGreen ? close : open
            let bodyLength = isGreen ? close - open : open - close

            viewModels.append(
                .init(
                    wick: .init(
                        origin: CGPoint(
                            x: CGFloat(i) * width + (width / 2 - 0.5),
                            y: (yLength - CGFloat(candle.high - low)) * yRatio
                        ),
                        size: CGSize(
                            width: 1,
                            height: CGFloat(candle.high - candle.low) * yRatio
                        )
                    ),
                    body: .init(
                        origin: CGPoint(
                            x: CGFloat(i) * width,
                            y: (yLength - CGFloat(bodyHigh - low)) * yRatio
                        ),
                        size: CGSize(
                            width: width,
                            height: CGFloat(bodyLength) * yRatio
                        )
                    ),
                    color: Color(isGreen ? UIColor.candleGreen : UIColor.candleRed))
            )
        }
        return viewModels
    }
}

// MARK: - ChartViewModel

extension ChartViewModel {

    struct CandleViewModel {
        let wick: CGRect
        let body: CGRect
        let color: Color
    }
}

// MARK: - Mock

extension ChartViewModel {

    static func mock() -> ChartViewModel {
        return .init(
            candles: (0..<30).map {
                .init(
                    open: Double($0 * 1000),
                    high: Double($0 * 1000 + 1000),
                    low: Double($0 * 1000 - 500),
                    close: Double($0 * 1000 + 500),
                    volume: Double(100),
                    period: Date().adding(minutes: TimeInterval(30 - $0))
                )
            }
        )
    }
}
