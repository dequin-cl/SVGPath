//
// Copyright © 2021 dequin_cl. All rights reserved.
//

import SVGPath
import XCTest

#if os(iOS)

    final class BezierTests: XCTestCase {
        func test_moveAndLine() throws {
            let path = try SVGPath("M2 4L2 6 4 6 4 4Z").bezier

            // 4 corners
            XCTAssert(path.contains(CGPoint(x: 2.01, y: 4.01)), "square should contain 2.01, 4.01")
            XCTAssert(path.contains(CGPoint(x: 3.99, y: 4.01)), "square should contain 3.99, 4.01")
            XCTAssert(path.contains(CGPoint(x: 3.99, y: 5.99)), "square should contain 3.99, 5.99")
            XCTAssert(path.contains(CGPoint(x: 2.01, y: 5.99)), "square should contain 2.01, 5.99")

            // just outside each corner
            XCTAssert(!path.contains(CGPoint(x: 1.99, y: 4.01)), "square should not contain 1.99, 4.01")
            XCTAssert(!path.contains(CGPoint(x: 4.01, y: 4.01)), "square should not contain 4.01, 4.01")
            XCTAssert(!path.contains(CGPoint(x: 1.99, y: 5.99)), "square should not contain 1.99, 5.99")
            XCTAssert(!path.contains(CGPoint(x: 4.01, y: 5.99)), "square should not contain 4.01, 5.99")
            XCTAssert(!path.contains(CGPoint(x: 2.01, y: 3.99)), "square should not contain 2.01, 3.99")
            XCTAssert(!path.contains(CGPoint(x: 3.99, y: 3.99)), "square should not contain 3.99, 3.99")
            XCTAssert(!path.contains(CGPoint(x: 3.99, y: 6.01)), "square should not contain 3.99, 6.01")
            XCTAssert(!path.contains(CGPoint(x: 2.01, y: 6.01)), "square should not contain 2.01, 6.01")
        }
    }

#endif
