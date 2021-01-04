//
// Created by p4rtiz4n on 25/12/2020.
//

import Foundation

struct ServiceDirectory {

    static var network: Network!

    static var assetsService: AssetsService!
    static var favouriteAssetsService: FavouriteAssetsService!

    enum Navigation {

        static var rootWireframeFactory: AssetsWireframeFactory!
    }

    enum Cache {

        static var image: ImageCacheService!
        static var candle: CandlesCacheService!
    }
    
    enum Formatter {

        static var currencyNonFractional: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            formatter.locale = Locale(identifier: "en_US")
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 0
            return formatter
        }()

        static var currencyFractional: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            formatter.locale = Locale(identifier: "en_US")
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
            return formatter
        }()

        static var percentage: NumberFormatter =  {
            let formatter = NumberFormatter()
            formatter.numberStyle = .percent
            formatter.minimumFractionDigits = 1
            formatter.maximumFractionDigits = 1
            return formatter
        }()
    }
}
