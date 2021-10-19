@testable import SVGPath
import XCTest

final class SVGPathTests: XCTestCase {
    func testBuildClosePathInstruction() {
        let instruction = Instruction()
        XCTAssertEqual(instruction.command, .closePath)
        XCTAssertEqual(instruction.correlation, .relative)
        XCTAssertNil(instruction.endPoint)
    }

    func testBuildAbsoluteMoveToInstructionA() {
        let instruction = Instruction(command: .moveTo, correlation: .absolute)

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
        let instruction = Instruction(command: .moveTo, correlation: .absolute)

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
        let instruction = Instruction(command: .moveTo, correlation: .absolute)

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
        let instruction = Instruction(command: .moveTo, correlation: .absolute)

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

    func testSingleMoveTo() throws {
        let result = SVGPath("M1 2").instructions

        let instruction = Instruction(command: .moveTo, correlation: .absolute)
        instruction.testHooks.addEndPoint(x: 1.0, y: 2.0)
        let expected = [instruction]

        try SVGAssertEqual(expected, result)
    }

    func testSingleMoveToNegativeValues() throws {
        let result = SVGPath("M1 -200").instructions

        let instruction = Instruction(command: .moveTo, correlation: .absolute)
        instruction.testHooks.addEndPoint(x: 1.0, y: -200.0)
        let expected = [instruction]

        try SVGAssertEqual(expected, result)
    }

    func testSingleMoveToFartherPoint() throws {
        let result = SVGPath("M100 200").instructions

        let instruction = Instruction(command: .moveTo, correlation: .absolute)
        instruction.testHooks.addEndPoint(x: 100.0, y: 200.0)

        let expected = [instruction]

        try SVGAssertEqual(expected, result)
    }

    func testMoveToWithLineToAbsolute() throws {
        let result = SVGPath("M1 2 3 4").instructions

        let moveTo = Instruction(command: .moveTo, correlation: .absolute)
        moveTo.testHooks.addEndPoint(x: 1.0, y: 2.0)
        let lineTo = Instruction(command: .lineTo, correlation: .absolute)
        lineTo.testHooks.addEndPoint(x: 3.0, y: 4.0)
        let expected = [moveTo, lineTo]

        XCTAssertEqual(result[0], moveTo)
        XCTAssertEqual(result[1], lineTo)

        try SVGAssertEqual(expected, result)
    }

    func testMoveToWithLineToRelative() throws {
        let result = SVGPath("M1 1 m1 2 3 4").instructions

        let moveTo = Instruction(command: .moveTo, correlation: .absolute)
        moveTo.testHooks.addEndPoint(x: 1.0, y: 1.0)
        let moveToRelative = Instruction(command: .moveTo, correlation: .relative)
        moveToRelative.testHooks.addEndPoint(x: 1.0, y: 2.0)
        let lineTo = Instruction(command: .lineTo, correlation: .relative)
        lineTo.testHooks.addEndPoint(x: 3.0, y: 4.0)
        let expected = [moveTo, moveToRelative, lineTo]

        try SVGAssertEqual(expected, result)
    }

    func testMoveToWithLineToAllAbsolute() throws {
        let result = SVGPath("M1 1 1 2 3 4").instructions

        let moveTo = Instruction(command: .moveTo, correlation: .absolute)
        moveTo.testHooks.addEndPoint(x: 1.0, y: 1.0)
        let lineTo1 = Instruction(command: .lineTo, correlation: .absolute)
        lineTo1.testHooks.addEndPoint(x: 1.0, y: 2.0)
        let lineTo2 = Instruction(command: .lineTo, correlation: .absolute)
        lineTo2.testHooks.addEndPoint(x: 3.0, y: 4.0)
        let expected = [moveTo, lineTo1, lineTo2]

        try SVGAssertEqual(expected, result)
    }

    //  If a relative moveto (m) appears as the first element of the path, then it is treated as a pair of absolute coordinates. In this case, subsequent pairs of coordinates are treated as relative even though the initial moveto is interpreted as an absolute moveto.
    func testSpacesIrrelevance() throws {
        let lhs = SVGPath("M 100 100 L 200 200").instructions
        let rhs = SVGPath("M100 100L200 200").instructions

        try SVGAssertEqual(lhs, rhs)
    }

    // "M 100 100 L 200 200"
    // "M100 100L200 200"
    // "M 100 200 L 200 100 -100 -200"

    func testMoveLinesAndNegativeValues() throws {
        let result = SVGPath("M 100 200 L 200 100 -100 -200").instructions

        let moveTo = Instruction(command: .moveTo, correlation: .absolute)
        moveTo.testHooks.addEndPoint(x: 100, y: 200)
        let lineTo1 = Instruction(command: .lineTo, correlation: .absolute)
        lineTo1.testHooks.addEndPoint(x: 200, y: 100)
        let lineTo2 = Instruction(command: .lineTo, correlation: .absolute)
        lineTo2.testHooks.addEndPoint(x: -100, y: -200)
        let expected = [moveTo, lineTo1, lineTo2]

        try SVGAssertEqual(expected, result)
    }

    func testMoveLinesAndNegativeValuesCanBeCompressed() throws {
        let lhs = SVGPath("M 100 200 L 200 100 -100 -200").instructions
        let rhs = SVGPath("M 100 200 200 100 -100 -200").instructions

        try SVGAssertEqual(lhs, rhs)
    }

    /*

     let path = "m 83.846207,283.12668 c 15.992614,-15.1728 -2.513154,-76.38272 -19.662265,-19.85549 -2.686628,2.07836 -3.844405,3.79032 -3.843936,5.68391 2.52e-4,1.13167 1.271934,3.67458 2.424778,4.8488 29.290043,-6.79271 2.902502,8.1524 11.570816,9.81493 1.988533,0.34976 6.85716,0.0978 9.510607,-0.49215 z"

     */

    func testExponentialNumber() throws {
        let path = "m 83.846207,283.12668 l 15.992614,-15.1728 -2.513154,3.79032 -3.843936,5.68391 2.52e-4,1.13167 z"

        let result = SVGPath(path).instructions

        let moveTo = Instruction(command: .moveTo, correlation: .relative)
        moveTo.testHooks.addEndPoint(x: "83.846207", y: "283.12668")
        let lineTo1 = Instruction(command: .lineTo, correlation: .relative)
        lineTo1.testHooks.addEndPoint(x: "15.992614", y: "-15.1728")
        let lineTo2 = Instruction(command: .lineTo, correlation: .relative)
        lineTo2.testHooks.addEndPoint(x: "-2.513154", y: "3.79032")
        let lineTo3 = Instruction(command: .lineTo, correlation: .relative)
        lineTo3.testHooks.addEndPoint(x: "-3.843936", y: "5.68391")
        let lineTo4 = Instruction(command: .lineTo, correlation: .relative)
        lineTo4.testHooks.addEndPoint(x: "2.52e-4", y: "1.13167")
        let lineTo5 = Instruction(command: .lineTo, correlation: .relative)
        lineTo5.testHooks.addEndPoint(x: "83.846207", y: "283.12668")

        let expected = [moveTo, lineTo1, lineTo2, lineTo3, lineTo4, lineTo5]

        try SVGAssertEqual(expected, result)
    }

    func testDrawTriangle() throws {
        let path = "M 100 100 L 300 100 L 200 300 z"

        let result = SVGPath(path).instructions

        let moveTo = Instruction(command: .moveTo, correlation: .absolute)
        moveTo.testHooks.addEndPoint(x: "100", y: "100")
        let lineTo1 = Instruction(command: .lineTo, correlation: .absolute)
        lineTo1.testHooks.addEndPoint(x: "300", y: "100")
        let lineTo2 = Instruction(command: .lineTo, correlation: .absolute)
        lineTo2.testHooks.addEndPoint(x: "200", y: "300")
        let lineTo3 = Instruction(command: .lineTo, correlation: .absolute)
        lineTo3.testHooks.addEndPoint(x: "100", y: "100")

        let expected = [moveTo, lineTo1, lineTo2, lineTo3]

        try SVGAssertEqual(expected, result)
    }

    // Horizontal

    func testHorizontalWithoutPreviewsPointReturnsEmpty() {
        let path = "H 100z"

        let result = SVGPath(path).instructions
        XCTAssertTrue(result.isEmpty)
    }

    func testHorizontalLine() throws {
        let path = "M 100,100H 200z"
        let expected = [
            moveTo((x: 100, y: 100)),
            horizontalLine((x: 200, y: 100)),
            line((x: 100, y: 100)),
        ]

        let result = SVGPath(path).instructions

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

        let result = SVGPath(path).instructions

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

        let result = SVGPath(path).instructions

        try SVGAssertEqual(expected, result)
    }

    // Vertical

    func test_createSquare() throws {
        let path = "M 10 10 H 90 V 90 H 10 L 10 10"
        let expected = [
            moveTo((x: 10, y: 10)),
            horizontalLine((x: 90, y: 10)),
            verticalLine((x: 90, y: 90)),
            horizontalLine((x: 10, y: 90)),
            line((x: 10, y: 10)),
        ]

        let result = SVGPath(path).instructions

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

        let result = SVGPath(path).instructions

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

        let result = SVGPath(path).instructions

        try SVGAssertEqual(expected, result)
    }

//    func test_simpleBezier() throws {
//        let path = "M 10 10 C 20 20, 40 20, 50 10"
//        let expected = [
//            moveTo((x: 10, y: 10)),
//            bezier(end:(x: 50, y: 10), control1:(x: 20, y: 20), control2: (x: 40, y: 20))
//        ]
//
//        let result = SVGPath(path).instructions
//
//        try SVGAssertEqual(expected, result)
//    }

//    func test_somethingElse() {
//        let path = "M30.18,1.72s-5.1-3-13.29,1.08S.28,17.63.66,27.06s8.81,5.5,8.81,5.5A37.79,37.79,0,0,0,22.76,18.87a81.39,81.39,0,0,0,7.11-16.3s-7.65,17.81-9.66,22.79-1.85,7.21-.54,8,4.63.72,11-7.55"
//
//        let result = SVGPath(path).instructions
//
//        print(result)
//    }

    // s-5.1-3-13.29,1.08   s (-5.1, -3)  (-13.29, 1.08)
    // S.28,17.63.66,27.06  S (0.28, 17.63)  (0.66, 27.06)

    // MARK: - Helpers

    private func cubicBezierCurve(_ to: (x: CGFloat, y: CGFloat), control1: (x: CGFloat, y: CGFloat), control2: (x: CGFloat, y: CGFloat), correlation: SVG.Correlation = .absolute) -> Instruction {
        let cubicBezierCurve = Instruction(command: .cubicBezierCurveTo, correlation: correlation)
        cubicBezierCurve.testHooks.addEndPoint(x: to.x, y: to.y)
        cubicBezierCurve.testHooks.addEndPoint(x: control1.x, y: control1.y)
        cubicBezierCurve.testHooks.addEndPoint(x: control2.x, y: control2.y)
        return cubicBezierCurve
    }

    private func moveTo(_ point: (x: CGFloat, y: CGFloat), correlation: SVG.Correlation = .absolute) -> Instruction {
        let moveTo = Instruction(command: .moveTo, correlation: correlation)
        moveTo.testHooks.addEndPoint(x: point.x, y: point.y)
        return moveTo
    }

    private func horizontalLine(_ point: (x: CGFloat, y: CGFloat), correlation: SVG.Correlation = .absolute) -> Instruction {
        let horizontalLine = Instruction(command: .horizontalLineTo, correlation: correlation)
        horizontalLine.testHooks.addEndPoint(x: point.x, y: point.y)
        return horizontalLine
    }

    private func verticalLine(_ point: (x: CGFloat, y: CGFloat), correlation: SVG.Correlation = .absolute) -> Instruction {
        let verticalLine = Instruction(command: .verticalLineTo, correlation: correlation)
        verticalLine.testHooks.addEndPoint(x: point.x, y: point.y)
        return verticalLine
    }

    private func line(_ point: (x: CGFloat, y: CGFloat), correlation: SVG.Correlation = .absolute) -> Instruction {
        let line = Instruction(command: .lineTo, correlation: correlation)
        line.testHooks.addEndPoint(x: point.x, y: point.y)
        return line
    }

    private func bezier(end: (x: CGFloat, y: CGFloat), control1 _: (x: CGFloat, y: CGFloat), control2 _: (x: CGFloat, y: CGFloat), correlation: SVG.Correlation = .absolute) -> Instruction {
        let line = Instruction(command: .cubicBezierCurveTo, correlation: correlation)
        line.testHooks.addEndPoint(x: end.x, y: end.y)
        return line
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
