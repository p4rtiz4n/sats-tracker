//
// Created by p4rtiz4n on 14/03/2021.
//

import SwiftUI

struct WidgetViewModel {
    let isMock: Bool
    let assets: [AssetViewModel]
}

// MARK: - AssetViewModel

extension WidgetViewModel {

    struct AssetViewModel {
        let title: String
        let price: String
        let pctChange: String
        let pctColor: Color
        let chart: ChartViewModel
    }
}

// MARK: - Convenience initializer

extension WidgetViewModel {

    init(assets: [Asset], info: [String: [Candle]], config: ConfigurationIntent?) {
        self.isMock = false
        self.assets = assets.first(n: 3).map {
            var priceStr = ""
            var pctStr: String = ""
            
            if let price = $0.priceUsd {
                let formatter = WidgetFormatter.price
                formatter.maximumFractionDigits = price > 10 ? 0 : 2
                priceStr = formatter.string(from: NSNumber(value: price)) ?? ""
            }
            
            if let pctChange = $0.changePercent24Hr {
                let formatter = WidgetFormatter.pctChange
                formatter.maximumFractionDigits = pctChange > 10 ? 0 : 1
                formatter.minimumFractionDigits = pctChange > 10 ? 0 : 1
                pctStr = formatter.string(from: NSNumber(value: abs(pctChange / 100))) ?? ""
            }
            
            return .init(
                title: $0.symbol,
                price: priceStr,
                pctChange: pctStr,
                pctColor: Color(
                    ($0.changePercent24Hr ?? 1) >= 0 ? UIColor.candleGreen : UIColor.candleRed
                ),
                chart: ChartViewModel(candles: info[$0.id] ?? [])
            )
        }
    }
}

// MARK: - Mock

extension WidgetViewModel {

    static func mock() -> WidgetViewModel {
        return .init(
            isMock: true,
            assets: [
                .init(
                    title: "BTC",
                    price: "$132,456",
                    pctChange: "12%",
                    pctColor: Color(UIColor.candleGreen),
                    chart: .mock()
                ),
                .init(
                    title: "ETH",
                    price: "$13,456",
                    pctChange: "12%",
                    pctColor: Color(UIColor.candleGreen),
                    chart: .mock()
                ),
                .init(
                    title: "USDT",
                    price: "$13,456",
                    pctChange: "12%",
                    pctColor: Color(UIColor.candleRed),
                    chart: .mock()
                )
            ]
        )
    }
}
