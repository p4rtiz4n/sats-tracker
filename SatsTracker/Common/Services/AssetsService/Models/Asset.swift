//
// Created by p4rtiz4n on 20/12/2020.
//

import Foundation

struct Asset: Equatable {

    let id: String
    let rank: Int
    let symbol: String
    let name: String
    let supply: Double?
    let maxSupply: Double?
    let marketCapUsd: Double?
    let volumeUsd24Hr: Double?
    let priceUsd: Double?
    let changePercent24Hr: Double?
    let vwap24Hr: Double?
}

// MARK: - Decodable

extension Asset: Decodable {

    enum CodingKeys: String, CodingKey {
        case id
        case rank
        case symbol
        case name
        case supply
        case maxSupply
        case marketCapUsd
        case volumeUsd24Hr
        case priceUsd
        case changePercent24Hr
        case vwap24Hr
    }

    init(from decoder: Decoder) throws {
        let cont = try decoder.container(keyedBy: CodingKeys.self)
        id = try cont.decode(String.self, forKey: .id)
        rank = try (try cont.decode(String.self, forKey: .rank)).int()
        symbol = try cont.decode(String.self, forKey: .symbol)
        name = try cont.decode(String.self, forKey: .name)
        supply = try? (try? cont.decode(String.self, forKey: .supply))?.double()
        maxSupply = try? (try? cont.decode(String.self, forKey: .maxSupply))?.double()
        marketCapUsd = try? (try? cont.decode(String.self, forKey: .marketCapUsd))?.double()
        volumeUsd24Hr = try? (try? cont.decode(String.self, forKey: .volumeUsd24Hr))?.double()
        priceUsd = try? (try? cont.decode(String.self, forKey: .priceUsd))?.double()
        changePercent24Hr = try? (try? cont.decode(String.self, forKey: .changePercent24Hr))?.double()
        vwap24Hr = try? (try? cont.decode(String.self, forKey: .vwap24Hr))?.double()
    }
}

// MARK: - Convenience initializer

extension Asset {

    init(id: String, rank: Int, symbol: String, name: String) {
        self.id = id
        self.rank = rank
        self.symbol = symbol
        self.name = name
        supply = nil
        maxSupply = nil
        marketCapUsd = nil
        volumeUsd24Hr = nil
        priceUsd = nil
        changePercent24Hr = nil
        vwap24Hr = nil
    }
}