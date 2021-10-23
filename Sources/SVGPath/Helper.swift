//
// Copyright © 2021 dequin_cl. All rights reserved.
//

import Foundation

enum Helper {
    // MARK: - Reflected control points https://www.w3.org/TR/SVG/paths.html#ReflectedControlPoints

    static func reflect(current: CGPoint, previousControl: CGPoint) -> CGPoint {
        CGPoint(x: 2 * current.x - previousControl.x, y: 2 * current.y - previousControl.y)
    }
}
