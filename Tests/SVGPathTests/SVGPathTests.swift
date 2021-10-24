@testable import SVGPath
import XCTest

final class SVGPathTests: XCTestCase {
    // MARK: - Instructions

    func testBuildClosePathInstruction() {
        let instruction = Instruction()
        XCTAssertEqual(instruction.command, .closePath)
        XCTAssertEqual(instruction.correlation, .relative)
        XCTAssertNil(instruction.endPoint)
    }

    func testBuildAbsoluteMoveToInstructionA() {
        let instruction = Instruction(.moveTo, correlation: .absolute)

        XCTAssertEqual(instruction.correlation, .absolute)
        XCTAssertNil(instruction.endPoint)

        instruction.addDigit("1")

        XCTAssertEqual(instruction.testHooks.digitAccumulator, "1")
        instruction.processSeparator()

        XCTAssertNil(instruction.endPoint)

        instruction.addDigit("2")

        XCTAssertEqual(instruction.testHooks.digitAccumulator, "2")
        instruction.processSeparator()

        XCTAssertNotNil(instruction.endPoint)
    }

    func testBuildAbsoluteMoveToInstruction() {
        let instruction = Instruction(.moveTo, correlation: .absolute)

        XCTAssertEqual(instruction.correlation, .absolute)
        XCTAssertNil(instruction.endPoint)

        instruction.addDigit("1")
        instruction.addDigit("0")
        instruction.addDigit("0")

        XCTAssertEqual(instruction.testHooks.digitAccumulator, "100")
        instruction.processSeparator()

        XCTAssertNil(instruction.endPoint)

        instruction.addDigit("2")
        instruction.addDigit("0")

        XCTAssertEqual(instruction.testHooks.digitAccumulator, "20")
        instruction.processSeparator()

        XCTAssertNotNil(instruction.endPoint)
    }

    func testBuildAbsoluteMoveToInstructionWithNegative() {
        let instruction = Instruction(.moveTo, correlation: .absolute)

        XCTAssertEqual(instruction.correlation, .absolute)
        XCTAssertNil(instruction.endPoint)

        instruction.addDigit("-")
        instruction.addDigit("1")
        instruction.addDigit("0")
        instruction.addDigit("0")

        XCTAssertEqual(instruction.testHooks.digitAccumulator, "-100")
        instruction.processSeparator()

        XCTAssertNil(instruction.endPoint)

        instruction.addDigit("2")
        instruction.addDigit("0")
        instruction.addDigit(".")
        instruction.addDigit("5")

        XCTAssertEqual(instruction.testHooks.digitAccumulator, "20.5")
        instruction.processSeparator()

        XCTAssertNotNil(instruction.endPoint)
        XCTAssertEqual(instruction.endPoint, CGPoint(x: -100, y: 20.5))
    }

    func testBuildAbsoluteMoveToInstructionWithDecimals() {
        let instruction = Instruction(.moveTo, correlation: .absolute)

        XCTAssertEqual(instruction.correlation, .absolute)
        XCTAssertNil(instruction.endPoint)

        instruction.addDigit("1")
        instruction.addDigit("1")
        instruction.addDigit(".")
        instruction.addDigit("5")

        XCTAssertEqual(instruction.testHooks.digitAccumulator, "11.5")
        instruction.processSeparator()

        XCTAssertNil(instruction.endPoint)

        instruction.addDigit("2")
        instruction.addDigit(".")
        instruction.addDigit("0")

        instruction.processSeparator()

        XCTAssertNotNil(instruction.endPoint)
        XCTAssertEqual(instruction.endPoint, CGPoint(x: 11.5, y: 2.0))
    }

    // MARK: - Move

    func testSingleMoveTo() throws {
        let expected = [moveTo((x: 1.0, y: 2.0))]
        let result = try SVGPath("M1 2").instructions

        try SVGAssertEqual(expected, result)
    }

    func testSingleMoveToNegativeValues() throws {
        let expected = [moveTo((x: 1.0, y: -200.0))]
        let result = try SVGPath("M1 -200").instructions

        try SVGAssertEqual(expected, result)
    }

    func testSingleMoveToFartherPoint() throws {
        let expected = [moveTo((x: 100.0, y: 200.0))]
        let result = try SVGPath("M100 200").instructions

        try SVGAssertEqual(expected, result)
    }

    func testMoveToWithLineToAbsolute() throws {
        let expected = [moveTo((x: 1.0, y: 2.0)), line((x: 3.0, y: 4.0))]
        let result = try SVGPath("M1 2 3 4").instructions

        try SVGAssertEqual(expected, result)
    }

    // MARK: - Line

    func testMoveToWithLineToRelative() throws {
        let expected = [
            moveTo((x: 1.0, y: 1.0)),
            moveTo((x: 1.0, y: 2.0), .relative),
            line((x: 3.0, y: 4.0), .relative),
        ]
        let result = try SVGPath("M1 1 m1 2 3 4").instructions

        try SVGAssertEqual(expected, result)
    }

    func testMoveToWithLineToAllAbsolute() throws {
        let expected = [moveTo((x: 1.0, y: 1.0)), line((x: 1.0, y: 2.0)), line((x: 3.0, y: 4.0))]
        let result = try SVGPath("M1 1 1 2 3 4").instructions

        try SVGAssertEqual(expected, result)
    }

    func test_startRelativeMove_deliversAbsoluteMoveAndRelativesSubsequentInstructions() throws {
        let path = "m 100 200 200 100 -100 -200"
        let expected = [
            moveTo((100, 200), .absolute),
            line((200, 100), .relative),
            line((-100, -200), .relative),
        ]
        let result = try SVGPath(path).instructions

        try SVGAssertEqual(expected, result)
    }

    func testSpacesIrrelevance() throws {
        let lhs = try SVGPath("M 100 100 L 200 200").instructions
        let rhs = try SVGPath("M100 100L200 200").instructions

        try SVGAssertEqual(lhs, rhs)
    }

    func test_spaces_doesNotChangeInstructions() throws {
        let expected = [
            moveTo((100, 100), .absolute),
            line((200, 200), .absolute),
        ]
        let result = try SVGPath("M 100 100 L 200 200").instructions
        try SVGAssertEqual(expected, result)

        let result2 = try SVGPath("M100 100L200 200").instructions
        try SVGAssertEqual(expected, result2)
    }

    func testMoveLinesAndNegativeValues() throws {
        let expected = [moveTo((x: 100, y: 200)), line((x: 200, y: 100)), line((x: -100, y: -200))]
        let result = try SVGPath("M 100 200 L 200 100 -100 -200").instructions

        try SVGAssertEqual(expected, result)
    }

    func testMoveLinesAndNegativeValuesCanBeCompressed() throws {
        let lhs = try SVGPath("M 100 200 L 200 100 -100 -200").instructions
        let rhs = try SVGPath("M 100 200 200 100 -100 -200").instructions

        try SVGAssertEqual(lhs, rhs)
    }

    /*

     let path = "m 83.846207,283.12668 c 15.992614,-15.1728 -2.513154,-76.38272 -19.662265,-19.85549 -2.686628,2.07836 -3.844405,3.79032 -3.843936,5.68391 2.52e-4,1.13167 1.271934,3.67458 2.424778,4.8488 29.290043,-6.79271 2.902502,8.1524 11.570816,9.81493 1.988533,0.34976 6.85716,0.0978 9.510607,-0.49215 z"

     */

    // MARK: - Exponential

    func testExponentialNumber() throws {
        let path = "m 83.846207,283.12668 l 15.992614,-15.1728 -2.513154,3.79032 -3.843936,5.68391 2.52e-4,1.13167 z"

        let moveTo = Instruction(.moveTo, correlation: .absolute)
        moveTo.testHooks.addEndPoint(x: "83.846207", y: "283.12668")
        let lineTo1 = Instruction(.lineTo, correlation: .relative)
        lineTo1.testHooks.addEndPoint(x: "15.992614", y: "-15.1728")
        let lineTo2 = Instruction(.lineTo, correlation: .relative)
        lineTo2.testHooks.addEndPoint(x: "-2.513154", y: "3.79032")
        let lineTo3 = Instruction(.lineTo, correlation: .relative)
        lineTo3.testHooks.addEndPoint(x: "-3.843936", y: "5.68391")
        let lineTo4 = Instruction(.lineTo, correlation: .relative)
        lineTo4.testHooks.addEndPoint(x: "2.52e-4", y: "1.13167")
        let lineTo5 = Instruction(.lineTo, correlation: .relative)
        lineTo5.testHooks.addEndPoint(x: "83.846207", y: "283.12668")

        let expected = [moveTo, lineTo1, lineTo2, lineTo3, lineTo4, lineTo5]

        let result = try SVGPath(path).instructions

        try SVGAssertEqual(expected, result)
    }

    func testDrawTriangle() throws {
        let path = "M 100 100 L 300 100 L 200 300 z"
        let expected = [moveTo((100, 100)), line((300, 100)), line((200, 300)), line((100, 100))]

        let result = try SVGPath(path).instructions

        try SVGAssertEqual(expected, result)
    }

    // MARK: - Horizontal

    func testHorizontalWithoutPreviewsPointReturnsEmpty() throws {
        let path = "H 100z"
        XCTAssertThrowsError(try SVGPath(path).instructions)
    }

    func testHorizontalLine() throws {
        let path = "M 100,100H 200z"
        let expected = [
            moveTo((x: 100, y: 100)),
            horizontalLine((x: 200, y: 100)),
            line((x: 100, y: 100)),
        ]

        let result = try SVGPath(path).instructions

        try SVGAssertEqual(expected, result)
    }

    func testHorizontalLine2() throws {
        let path = "M 100,100H 200 300z"
        let expected = [
            moveTo((x: 100, y: 100)),
            horizontalLine((x: 200, y: 100)),
            horizontalLine((x: 300, y: 100)),
            line((x: 100, y: 100)),
        ]

        let result = try SVGPath(path).instructions

        try SVGAssertEqual(expected, result)
    }

    func testMultipleHorizontalLine() throws {
        let path = "M 100,100H 200 300 400z"
        let expected = [
            moveTo((x: 100, y: 100)),
            horizontalLine((x: 200, y: 100)),
            horizontalLine((x: 300, y: 100)),
            horizontalLine((x: 400, y: 100)),
            line((x: 100, y: 100)),
        ]

        let result = try SVGPath(path).instructions

        try SVGAssertEqual(expected, result)
    }

    // MARK: - Vertical

    func test_createSquare() throws {
        let path = "M 10 10 H 90 V 90 H 10 L 10 10"
        let expected = [
            moveTo((x: 10, y: 10)),
            horizontalLine((x: 90, y: 10)),
            verticalLine((x: 90, y: 90)),
            horizontalLine((x: 10, y: 90)),
            line((x: 10, y: 10)),
        ]

        let result = try SVGPath(path).instructions

        try SVGAssertEqual(expected, result)
    }

    func test_closeLoop_CreateSquare() throws {
        let path = "M 10 10 H 90 V 90 H 10z"
        let expected = [
            moveTo((x: 10, y: 10)),
            horizontalLine((x: 90, y: 10)),
            verticalLine((x: 90, y: 90)),
            horizontalLine((x: 10, y: 90)),
            line((x: 10, y: 10)),
        ]

        let result = try SVGPath(path).instructions

        try SVGAssertEqual(expected, result)
    }

    func test_noClose_leftSquareUnfinished() throws {
        let path = "M 10 10 H 90 V 90 H 10"
        let expected = [
            moveTo((x: 10, y: 10)),
            horizontalLine((x: 90, y: 10)),
            verticalLine((x: 90, y: 90)),
            horizontalLine((x: 10, y: 90)),
        ]

        let result = try SVGPath(path).instructions

        try SVGAssertEqual(expected, result)
    }

    // MARK: - Cubic Bezier

    func test_simpleBezier() throws {
        let path = "M 10 10 C 20 20, 40 20, 50 10"
        let expected = [
            moveTo((x: 10, y: 10), .absolute),
            cubicBezierCurve((x: 50, y: 10), control1: (x: 20, y: 20), control2: (x: 40, y: 20), .absolute),
        ]

        let result = try SVGPath(path).instructions

        try SVGAssertEqual(expected, result)
    }

    func test_simpleSmoothBezier() throws {
        let path = "M 10 10 S 20 20, 40 20"
        let expected = [
            moveTo((x: 10, y: 10), .absolute),
            cubicSmoothBezier((x: 40, y: 20), control1: (x: 10, y: 10), control2: (x: 20, y: 20), .absolute),
        ]

        let result = try SVGPath(path).instructions

        try SVGAssertEqual(expected, result)
    }

    //    func test_somethingElse() {
    //        let path = "M30.18,1.72s-5.1-3-13.29,1.08S.28,17.63.66,27.06s8.81,5.5,8.81,5.5A37.79,37.79,0,0,0,22.76,18.87a81.39,81.39,0,0,0,7.11-16.3s-7.65,17.81-9.66,22.79-1.85,7.21-.54,8,4.63.72,11-7.55"
    //
    //        let result = try SVGPath(path).instructions
    //
    //        print(result)
    //    }

    // s-5.1-3-13.29,1.08   s (-5.1, -3)  (-13.29, 1.08)
    // S.28,17.63.66,27.06  S (0.28, 17.63)  (0.66, 27.06)

    func test_smoothBezier_withNegatives() throws {
        let path = "M30.18,1.72s-5.1-3-13.29,1.08"
        let expected = [
            moveTo((30.18, 1.72), .absolute),
            cubicSmoothBezier((-13.29, 1.08), control1: (30.18, 1.72), control2: (-5.1, -3), .relative),
        ]
        let result = try SVGPath(path).instructions
        try SVGAssertEqual(expected, result)
    }

    func test_twoSmoothBezier() throws {
        let path = "M30.18,1.72s-5.1-3-13.29,1.08S.28,17.63.66,27.06s8.81,5.5,8.81,5.5"
        let reflective1 = Helper.reflect(current: CGPoint(x: -13.29, y: 1.08), previousControl: CGPoint(x: -5.1, y: -3))
        let reflective2 = Helper.reflect(current: CGPoint(x: 0.66, y: 27.06), previousControl: CGPoint(x: 0.28, y: 17.63))
        let expected = [
            moveTo((30.18, 1.72), .absolute),
            cubicSmoothBezier((-13.29, 1.08), control1: (30.18, 1.72), control2: (-5.1, -3), .relative),
            cubicSmoothBezier((0.66, 27.06), control1: (reflective1.x, reflective1.y), control2: (0.28, 17.63), .absolute),
            cubicSmoothBezier((8.81, 5.5), control1: (reflective2.x, reflective2.y), control2: (8.81, 5.5), .relative),
        ]
        let result = try SVGPath(path).instructions
        try SVGAssertEqual(expected, result)
    }

    func test() throws {
        let path = "M100,200 C100,100 250,100 250,200 S400,300 400,200"
        let reflective = Helper.reflect(current: CGPoint(x: 250, y: 200), previousControl: CGPoint(x: 250, y: 100))
        let expected = [
            moveTo((100, 200), .absolute),
            cubicBezierCurve((250, 200), control1: (100, 100), control2: (250, 100), .absolute),
            cubicSmoothBezier((400, 200), control1: (reflective.x, reflective.y), control2: (400, 300), .absolute),
        ]
        let result = try SVGPath(path).instructions
        try SVGAssertEqual(expected, result)
    }

    // MARK: - Quadratic Bezier

    func test_create_quadratic_bezier() throws {
        let path = "M200,300 Q400,50 600,300 T1000,300"
        let expected = [
            moveTo((200, 300), .absolute),
            quadraticBezierCurve((600, 300), control1: (400, 50), .absolute),
            quadraticBezierSmoothCurve((1000, 300), control1: (800, 550)),
        ]
        let result = try SVGPath(path).instructions
        try SVGAssertEqual(expected, result)
    }

    // MARK: - Elliptical Arc

    func test_threeQuarters_circle() throws {
//        A 37.79,37.79, 0, 0, 0, 22.76, 18.87
        let path = "M300,200 h-150 a150,150 0 1,0 150,-150 z"
        let expected = [
            moveTo((300, 200), .absolute),
            horizontalLine((-150, 200), .relative),
            ellipticalArc((x: 150, y: -150), (x: 150, y: 150), degrees: 0, largeArc: true, sweep: false, .relative),
            line((300, 200), .relative),
        ]
        let result = try SVGPath(path).instructions
        print(result)
        try SVGAssertEqual(expected, result)
    }

    func test_multiple_arcs() throws {
        let path = """
        M600,350
        l 50,-25
        a25,25 -30 0,1 50,-25
        l 50,-25
        a25,50 -30 0,1 50,-25
        l 50,-25
        a25,75 -30 0,1 50,-25
        l 50,-25
        a25,100 -30 0,1 50,-25
        l 50,-25
        """
        let expected = [
            moveTo((600, 350), .absolute),
            line((50, -25), .relative),
            ellipticalArc((50, -25), (25, 25), degrees: -30, largeArc: false, sweep: true, .relative),
            line((50, -25), .relative),
            ellipticalArc((50, -25), (25, 50), degrees: -30, largeArc: false, sweep: true, .relative),
            line((50, -25), .relative),
            ellipticalArc((50, -25), (25, 75), degrees: -30, largeArc: false, sweep: true, .relative),
            line((50, -25), .relative),
            ellipticalArc((50, -25), (25, 100), degrees: -30, largeArc: false, sweep: true, .relative),
            line((50, -25), .relative),
        ]
        let result = try SVGPath(path).instructions
        try SVGAssertEqual(expected, result)
    }
}

/*

 def parse_path(path_data):
     digit_exp = '0123456789eE'
     comma_wsp = ', \t\n\r\f\v'
     drawto_command = 'MmZzLlHhVvCcSsQqTtAa'
     sign = '+-'
     exponent = 'eE'
     float = False
     entity = ''
     for char in path_data:
         if char in digit_exp:
             entity += char
         elif char in comma_wsp and entity:
             yield entity
             float = False
             entity = ''
         elif char in drawto_command:
             if entity:
                 yield entity
                 float = False
                 entity = ''
             yield char
         elif char == '.':
             if float:
                 yield entity
                 entity = '.'
             else:
                 entity += '.'
                 float = True
         elif char in sign:
             if entity and entity[-1] not in exponent:
                 yield entity
                 float = False
                 entity = char
             else:
                 entity += char
     if entity:
         yield entity

 */
