//
// Created by p4rtiz4n on 14/03/2021.
//

import CoreGraphics

extension CGRect {
    
    var minXminY: CGPoint {
        return .init(x: minX, y: minY)
    }

    var maxXminY: CGPoint {
        return .init(x: maxX, y: minY)
    }

    var minXmaxY: CGPoint {
        return .init(x: minX, y: maxY)
    }

    var maxXmaxY: CGPoint {
        return .init(x: maxX, y: maxY)
    }
    
    var midXminY: CGPoint {
        return .init(x: midX, y: minY)
    }

    var midXmaxY: CGPoint {
        return .init(x: midX, y: maxY)
    }
}
