//
// Created by p4rtiz4n on 28/12/2020.
//

import Foundation

struct Candle {

    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double
    let period: Date
}

// MARK: - Decodable

extension Candle: Decodable {

    enum CodingKeys: String, CodingKey {
        case open
        case high
        case low
        case close
        case volume
        case period
    }

    init(from decoder: Decoder) throws {
        let cont = try decoder.container(keyedBy: CodingKeys.self)
        open = try (try cont.decode(String.self, forKey: .open)).double()
        high = try (try cont.decode(String.self, forKey: .high)).double()
        low = try (try cont.decode(String.self, forKey: .low)).double()
        close = try (try cont.decode(String.self, forKey: .close)).double()
        volume = try (try cont.decode(String.self, forKey: .volume)).double()
        period = Date(
            timeIntervalSince1970: try cont.decode(Double.self, forKey: .period)
        )
    }
}