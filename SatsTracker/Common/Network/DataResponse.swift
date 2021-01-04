//
// Created by p4rtiz4n on 21/12/2020.
//

import Foundation

struct DataResponse<T: Decodable>: Decodable {
    let data: Array<T>
}