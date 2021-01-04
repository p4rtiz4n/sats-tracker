//
// Created by p4rtiz4n on 28/12/2020.
//

import Foundation

struct Market: Equatable {

    let exchangeId: String      // eg: "Binance"
    let baseId: String          // eg: "bitcoin"
    let quoteId: String         // eg: "tether"
    let baseSymbol: String      // eg: "BTC"
    let quoteSymbol: String     // eg: "USDT"
    let volumeUsd24Hr: Double?  // eg: "277775213.1923032624064566"
    let priceUsd: Double?       // eg: "6263.8645034633024446"
    let volumePercent: Double?  // eg: "7.4239157877678087
}

// MARK: - Decodable

extension Market: Decodable {

    enum CodingKeys: String, CodingKey {
        case exchangeId
        case baseId
        case quoteId
        case baseSymbol
        case quoteSymbol
        case volumeUsd24Hr
        case priceUsd
        case volumePercent
    }

    init(from decoder: Decoder) throws {
        let cont = try decoder.container(keyedBy: CodingKeys.self)
        exchangeId = try cont.decode(String.self, forKey: .exchangeId)
        baseId = try cont.decode(String.self, forKey: .baseId)
        quoteId = try cont.decode(String.self, forKey: .quoteId)
        baseSymbol = try cont.decode(String.self, forKey: .baseSymbol)
        quoteSymbol = try cont.decode(String.self, forKey: .quoteSymbol)
        volumeUsd24Hr = try? (try? cont.decode(String.self, forKey: .volumeUsd24Hr))?.double()
        priceUsd = try? (try? cont.decode(String.self, forKey: .priceUsd))?.double()
        volumePercent = try? (try? cont.decode(String.self, forKey: .volumePercent))?.double()
    }
}