@testable import SVGPath
import XCTest

final class SVGPathTests: XCTestCase {
    func testBuildClosePathInstruction() {
        let instruction = Instruction()
        XCTAssertEqual(instruction.command, .closePath)
        XCTAssertEqual(instruction.correlation, .relative)
        XCTAssertNil(instruction.point)
//            XCTAssertEqual(instruction.point, .zero)
//            XCTAssertEqual(instruction.control1, .zero)
//            XCTAssertEqual(instruction.control2, .zero)
    }

    func testBuildAbsoluteMoveToInstructionA() {
        let instruction = Instruction(command: .moveTo, correlation: .absolute)

        XCTAssertEqual(instruction.correlation, .absolute)
        XCTAssertNil(instruction.point)

        instruction.addDigit("1")

        XCTAssertEqual(instruction.testHooks.digitAccumulator, "1")
        instruction.processSeparator()

        XCTAssertNil(instruction.point)

        instruction.addDigit("2")

        XCTAssertEqual(instruction.testHooks.digitAccumulator, "2")
        instruction.processSeparator()

        XCTAssertNotNil(instruction.point)
    }

    func testBuildAbsoluteMoveToInstruction() {
        let instruction = Instruction(command: .moveTo, correlation: .absolute)

        XCTAssertEqual(instruction.correlation, .absolute)
        XCTAssertNil(instruction.point)

        instruction.addDigit("1")
        instruction.addDigit("0")
        instruction.addDigit("0")

        XCTAssertEqual(instruction.testHooks.digitAccumulator, "100")
        instruction.processSeparator()

        XCTAssertNil(instruction.point)

        instruction.addDigit("2")
        instruction.addDigit("0")

        XCTAssertEqual(instruction.testHooks.digitAccumulator, "20")
        instruction.processSeparator()

        XCTAssertNotNil(instruction.point)
    }

    func testBuildAbsoluteMoveToInstructionWithNegative() {
        let instruction = Instruction(command: .moveTo, correlation: .absolute)

        XCTAssertEqual(instruction.correlation, .absolute)
        XCTAssertNil(instruction.point)

        instruction.addDigit("-")
        instruction.addDigit("1")
        instruction.addDigit("0")
        instruction.addDigit("0")

        XCTAssertEqual(instruction.testHooks.digitAccumulator, "-100")
        instruction.processSeparator()

        XCTAssertNil(instruction.point)

        instruction.addDigit("2")
        instruction.addDigit("0")
        instruction.addDigit(".")
        instruction.addDigit("5")

        XCTAssertEqual(instruction.testHooks.digitAccumulator, "20.5")
        instruction.processSeparator()

        XCTAssertNotNil(instruction.point)
        XCTAssertEqual(instruction.point, CGPoint(x: -100, y: 20.5))
    }

    func testBuildAbsoluteMoveToInstructionWithDecimals() {
        let instruction = Instruction(command: .moveTo, correlation: .absolute)

        XCTAssertEqual(instruction.correlation, .absolute)
        XCTAssertNil(instruction.point)

        instruction.addDigit("1")
        instruction.addDigit("1")
        instruction.addDigit(".")
        instruction.addDigit("5")

        XCTAssertEqual(instruction.testHooks.digitAccumulator, "11.5")
        instruction.processSeparator()

        XCTAssertNil(instruction.point)

        instruction.addDigit("2")
        instruction.addDigit(".")
        instruction.addDigit("0")

        instruction.processSeparator()

        XCTAssertNotNil(instruction.point)
        XCTAssertEqual(instruction.point, CGPoint(x: 11.5, y: 2.0))
    }

    func testSingleMoveTo() throws {
        let result = SVGPath("M1 2").instructions

        let instruction = Instruction(command: .moveTo, correlation: .absolute)
        instruction.testHooks.addPoint(x: 1.0, y: 2.0)
        let expected = [instruction]

        try SVGAssertEqual(expected, result)
    }

    func testSingleMoveToNegativeValues() throws {
        let result = SVGPath("M1 -200").instructions

        let instruction = Instruction(command: .moveTo, correlation: .absolute)
        instruction.testHooks.addPoint(x: 1.0, y: -200.0)
        let expected = [instruction]

        try SVGAssertEqual(expected, result)
    }

    func testSingleMoveToFartherPoint() throws {
        let result = SVGPath("M100 200").instructions

        let instruction = Instruction(command: .moveTo, correlation: .absolute)
        instruction.testHooks.addPoint(x: 100.0, y: 200.0)

        let expected = [instruction]

        try SVGAssertEqual(expected, result)
    }

    func testMoveToWithLineToAbsolute() throws {
        let result = SVGPath("M1 2 3 4").instructions

        let moveTo = Instruction(command: .moveTo, correlation: .absolute)
        moveTo.testHooks.addPoint(x: 1.0, y: 2.0)
        let lineTo = Instruction(command: .lineTo, correlation: .absolute)
        lineTo.testHooks.addPoint(x: 3.0, y: 4.0)
        let expected = [moveTo, lineTo]

        XCTAssertEqual(result[0], moveTo)
        XCTAssertEqual(result[1], lineTo)

        try SVGAssertEqual(expected, result)
    }

    func testMoveToWithLineToRelative() throws {
        let result = SVGPath("M1 1 m1 2 3 4").instructions

        let moveTo = Instruction(command: .moveTo, correlation: .absolute)
        moveTo.testHooks.addPoint(x: 1.0, y: 1.0)
        let moveToRelative = Instruction(command: .moveTo, correlation: .relative)
        moveToRelative.testHooks.addPoint(x: 1.0, y: 2.0)
        let lineTo = Instruction(command: .lineTo, correlation: .relative)
        lineTo.testHooks.addPoint(x: 3.0, y: 4.0)
        let expected = [moveTo, moveToRelative, lineTo]

        try SVGAssertEqual(expected, result)
    }

    func testMoveToWithLineToAllAbsolute() throws {
        let result = SVGPath("M1 1 1 2 3 4").instructions

        let moveTo = Instruction(command: .moveTo, correlation: .absolute)
        moveTo.testHooks.addPoint(x: 1.0, y: 1.0)
        let lineTo1 = Instruction(command: .lineTo, correlation: .absolute)
        lineTo1.testHooks.addPoint(x: 1.0, y: 2.0)
        let lineTo2 = Instruction(command: .lineTo, correlation: .absolute)
        lineTo2.testHooks.addPoint(x: 3.0, y: 4.0)
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
        moveTo.testHooks.addPoint(x: 100, y: 200)
        let lineTo1 = Instruction(command: .lineTo, correlation: .absolute)
        lineTo1.testHooks.addPoint(x: 200, y: 100)
        let lineTo2 = Instruction(command: .lineTo, correlation: .absolute)
        lineTo2.testHooks.addPoint(x: -100, y: -200)
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
        moveTo.testHooks.addPoint(x: "83.846207", y: "283.12668")
        let lineTo1 = Instruction(command: .lineTo, correlation: .relative)
        lineTo1.testHooks.addPoint(x: "15.992614", y: "-15.1728")
        let lineTo2 = Instruction(command: .lineTo, correlation: .relative)
        lineTo2.testHooks.addPoint(x: "-2.513154", y: "3.79032")
        let lineTo3 = Instruction(command: .lineTo, correlation: .relative)
        lineTo3.testHooks.addPoint(x: "-3.843936", y: "5.68391")
        let lineTo4 = Instruction(command: .lineTo, correlation: .relative)
        lineTo4.testHooks.addPoint(x: "2.52e-4", y: "1.13167")
        let lineTo5 = Instruction(command: .lineTo, correlation: .relative)
        lineTo5.testHooks.addPoint(x: "83.846207", y: "283.12668")

        let expected = [moveTo, lineTo1, lineTo2, lineTo3, lineTo4, lineTo5]

        try SVGAssertEqual(expected, result)
    }

    func testDrawTriangle() throws {
        let path = "M 100 100 L 300 100 L 200 300 z"

        let result = SVGPath(path).instructions

        let moveTo = Instruction(command: .moveTo, correlation: .absolute)
        moveTo.testHooks.addPoint(x: "100", y: "100")
        let lineTo1 = Instruction(command: .lineTo, correlation: .absolute)
        lineTo1.testHooks.addPoint(x: "300", y: "100")
        let lineTo2 = Instruction(command: .lineTo, correlation: .absolute)
        lineTo2.testHooks.addPoint(x: "200", y: "300")
        let lineTo3 = Instruction(command: .lineTo, correlation: .absolute)
        lineTo3.testHooks.addPoint(x: "100", y: "100")

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
            moveTo((x: "100", y: "100")),
            horizontalLine((x: "200", y: "100")),
            line((x: "100", y: "100")),
        ]

        let result = SVGPath(path).instructions

        try SVGAssertEqual(expected, result)
    }

    func testHorizontalLine2() throws {
        let path = "M 100,100H 200 300z"
        let expected = [
            moveTo((x: "100", y: "100")),
            horizontalLine((x: "200", y: "100")),
            horizontalLine((x: "300", y: "100")),
            line((x: "100", y: "100")),
        ]

        let result = SVGPath(path).instructions

        try SVGAssertEqual(expected, result)
    }

    func testMultipleHorizontalLine() throws {
        let path = "M 100,100H 200 300 400z"
        let expected = [
            moveTo((x: "100", y: "100")),
            horizontalLine((x: "200", y: "100")),
            horizontalLine((x: "300", y: "100")),
            horizontalLine((x: "400", y: "100")),
            line((x: "100", y: "100")),
        ]

        let result = SVGPath(path).instructions

        try SVGAssertEqual(expected, result)
    }

    // MARK: - Helpers

    private func moveTo(_ point: (x: String, y: String), correlation: SVG.Correlation = .absolute) -> Instruction {
        let moveTo = Instruction(command: .moveTo, correlation: correlation)
        moveTo.testHooks.addPoint(x: point.x, y: point.y)
        return moveTo
    }

    private func horizontalLine(_ point: (x: String, y: String), correlation: SVG.Correlation = .absolute) -> Instruction {
        let horizontalLine = Instruction(command: .horizontalLineTo, correlation: correlation)
        horizontalLine.testHooks.addPoint(x: point.x, y: point.y)
        return horizontalLine
    }

    private func line(_ point: (x: String, y: String), correlation: SVG.Correlation = .absolute) -> Instruction {
        let line = Instruction(command: .lineTo, correlation: correlation)
        line.testHooks.addPoint(x: point.x, y: point.y)
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
