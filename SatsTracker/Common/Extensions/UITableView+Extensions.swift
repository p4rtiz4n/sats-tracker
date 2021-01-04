//
// Created by p4rtiz4n on 30/12/2020.
//

import UIKit

extension UITableView {

    func dequeue<T: UITableViewCell>(_: T.Type, for idxPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(
            withIdentifier: "\(T.self)",
            for: idxPath
        ) as? T else {
            fatalError("Failed to deque cell with id \(T.self)")
        }
        return cell
    }
}
