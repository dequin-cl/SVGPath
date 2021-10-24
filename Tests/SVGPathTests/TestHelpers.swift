@testable import SVGPath
import XCTest

func SVGAssertEqual(_ expected: [Instruction], _ received: [Instruction], file: StaticString = #filePath, line: UInt = #line) throws {
    guard !expected.isEmpty, !received.isEmpty else {
        XCTFail("Empty instructions", file: file, line: line)
        return
    }

    XCTAssertEqual(expected.count, received.count, "Number of instructions should be the same. Expected: \(expected) but received: \(received)", file: file, line: line)

    try zip(expected, received).forEach {
        try compare(expected: $0, received: $1, file: file, line: line)
    }
}

private func compare(expected: Instruction, received: Instruction, file: StaticString = #filePath, line: UInt = #line) throws {
    XCTAssertEqual(expected.command, received.command, "command should be the same", file: file, line: line)
    try compareProperties(expected.correlation, received.correlation, in: received.command, property: "correlation", file: file, line: line)
    try compareProperties(expected.endPoint, received.endPoint, in: received.command, property: "endPoint", file: file, line: line)
    try compareProperties(expected.control1, received.control1, in: received.command, property: "control1", file: file, line: line)
    try compareProperties(expected.control2, received.control2, in: received.command, property: "control2", file: file, line: line)
    try compareProperties(expected.radius, received.radius, in: received.command, property: "radius", file: file, line: line)
    try compareProperties(expected.rotation, received.rotation, in: received.command, property: "rotation", file: file, line: line)
    try compareProperties(expected.useLargeArc, received.useLargeArc, in: received.command, property: "useLargeArc", file: file, line: line)
    try compareProperties(expected.useSweep, received.useSweep, in: received.command, property: "useSweep", file: file, line: line)
}

private func compareProperties<T: Equatable>(_ expected: T?, _ received: T?, in command: Command, property: String, file: StaticString = #filePath, line: UInt = #line) throws {
    // If we do not expect a value, we can continue.
    guard let expected = expected else { return }

    let result = try XCTUnwrap(received, "Expected \(property) in received but got nil", file: file, line: line)

    XCTAssertEqual(expected, received, "Expected \(command) \(property): \(expected), but got: \(result)", file: file, line: line)
}

// MARK: - Instructions

func moveTo(_ point: (x: CGFloat, y: CGFloat), _ correlation: SVG.Correlation = .absolute) -> Instruction {
    let moveTo = Instruction(.moveTo, correlation: correlation)
    moveTo.testHooks.addEndPoint(x: point.x, y: point.y)
    return moveTo
}

func moveTo(_ point: (x: String, y: String), _ correlation: SVG.Correlation = .absolute) -> Instruction {
    let moveTo = Instruction(.moveTo, correlation: correlation)
    moveTo.testHooks.addEndPoint(x: point.x, y: point.y)
    return moveTo
}

func horizontalLine(_ point: (x: CGFloat, y: CGFloat), _ correlation: SVG.Correlation = .absolute) -> Instruction {
    let horizontalLine = Instruction(.horizontalLineTo, correlation: correlation)
    horizontalLine.testHooks.addEndPoint(x: point.x, y: point.y)
    return horizontalLine
}

func verticalLine(_ point: (x: CGFloat, y: CGFloat), _ correlation: SVG.Correlation = .absolute) -> Instruction {
    let verticalLine = Instruction(.verticalLineTo, correlation: correlation)
    verticalLine.testHooks.addEndPoint(x: point.x, y: point.y)
    return verticalLine
}

func line(_ point: (x: CGFloat, y: CGFloat), _ correlation: SVG.Correlation = .absolute) -> Instruction {
    let line = Instruction(.lineTo, correlation: correlation)
    line.testHooks.addEndPoint(x: point.x, y: point.y)
    return line
}

func cubicBezierCurve(_ to: (x: CGFloat, y: CGFloat), control1: (x: CGFloat, y: CGFloat), control2: (x: CGFloat, y: CGFloat), _ correlation: SVG.Correlation = .absolute) -> Instruction {
    let instruction = Instruction(.cubicBezierCurveTo, correlation: correlation)
    instruction.testHooks.addEndPoint(x: to.x, y: to.y)
    instruction.testHooks.addControl1(x: control1.x, y: control1.y)
    instruction.testHooks.addControl2(x: control2.x, y: control2.y)
    return instruction
}

func cubicSmoothBezier(_ end: (x: CGFloat, y: CGFloat), control1: (x: CGFloat, y: CGFloat), control2: (x: CGFloat, y: CGFloat), _ correlation: SVG.Correlation = .absolute) -> Instruction {
    let instruction = Instruction(.cubicBezierSmoothCurveTo, correlation: correlation)
    instruction.testHooks.addEndPoint(x: end.x, y: end.y)
    instruction.testHooks.addControl1(x: control1.x, y: control1.y)
    instruction.testHooks.addControl2(x: control2.x, y: control2.y)
    return instruction
}

func quadraticBezierCurve(_ to: (x: CGFloat, y: CGFloat), control1: (x: CGFloat, y: CGFloat), _ correlation: SVG.Correlation = .absolute) -> Instruction {
    let instruction = Instruction(.quadraticBezierCurveTo, correlation: correlation)
    instruction.testHooks.addEndPoint(x: to.x, y: to.y)
    instruction.testHooks.addControl1(x: control1.x, y: control1.y)
    return instruction
}

func quadraticBezierSmoothCurve(_ to: (x: CGFloat, y: CGFloat), control1: (x: CGFloat, y: CGFloat), _ correlation: SVG.Correlation = .absolute) -> Instruction {
    let instruction = Instruction(.quadraticBezierSmoothCurveTo, correlation: correlation)
    instruction.testHooks.addEndPoint(x: to.x, y: to.y)
    instruction.testHooks.addControl1(x: control1.x, y: control1.y)
    return instruction
}

func ellipticalArc(_ to: (x: CGFloat, y: CGFloat), _ radius: (x: CGFloat, y: CGFloat), degrees: CGFloat, largeArc: Bool, sweep: Bool, _ correlation: SVG.Correlation = .absolute) -> Instruction {
    let instruction = Instruction(.ellipticalArc, correlation: correlation)

    instruction.testHooks.addRadius(x: radius.x, y: radius.y)
    instruction.testHooks.addRotation(degrees: degrees)
    instruction.testHooks.useLargeArc(largeArc)
    instruction.testHooks.useSweep(sweep)
    instruction.testHooks.addEndPoint(x: to.x, y: to.y)

    return instruction
}
