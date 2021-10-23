//
// Copyright © 2021 dequin_cl. All rights reserved.
//

@testable import SVGPath
import XCTest

final class HelpersTests: XCTestCase {
    func test_reflection() {
        let previousControlPoint = CGPoint(x: 400, y: 50)
        let currentPoint = CGPoint(x: 600, y: 300)

        let reflected = Helper.reflect(current: currentPoint, previousControl: previousControlPoint)
        XCTAssertEqual(CGPoint(x: 800, y: 550), reflected)
    }
}
