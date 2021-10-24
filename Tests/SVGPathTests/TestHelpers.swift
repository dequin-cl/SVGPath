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
