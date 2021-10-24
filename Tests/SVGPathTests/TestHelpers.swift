@testable import SVGPath
import XCTest

func SVGAssertEqual(_ expected: [Instruction], _ received: [Instruction], file: StaticString = #filePath, line: UInt = #line) throws {
    guard !expected.isEmpty, !received.isEmpty else {
        XCTFail("Empty instructions", file: file, line: line)
        return
    }

    XCTAssertEqual(expected.count, received.count, "Number of instructions should be the same. Expected: \(expected) but received: \(received)", file: file, line: line)

    guard expected.count == received.count else { return }

    for i in 0 ..< expected.count {
        XCTAssertEqual(expected[i].command, received[i].command, "command should be the same", file: file, line: line)
        XCTAssertEqual(
            expected[i].correlation, received[i].correlation,
            "Expected \(expected[i].correlation) \(expected[i]), but received \(received[i].correlation) \(received[i])",
            file: file,
            line: line
        )

        XCTAssertEqual(
            expected[i].endPoint,
            received[i].endPoint,
            "Expected \(expected[i].command) endPoint: \(expected[i].endPoint!) but received: \(expected[i].command) -> \(String(describing: received[i].endPoint))",
            file: file,
            line: line
        )
        XCTAssertEqual(
            expected[i].control1,
            received[i].control1,
            "Expected control1: \(expected[i].control1!) but received: \(String(describing: received[i].control1))",
            file: file,
            line: line
        )
        XCTAssertEqual(
            expected[i].control2,
            received[i].control2,
            "Expected control2: \(expected[i].control2!) but received: \(String(describing: received[i].control2))",
            file: file,
            line: line
        )
        
        try compareProperties(expected[i].radius, received[i].radius, in: received[i].command, property: "radius", file: file, line: line)
        try compareProperties(expected[i].rotation, received[i].rotation, in: received[i].command, property: "rotation", file: file, line: line)
        try compareProperties(expected[i].useLargeArc, received[i].useLargeArc, in: received[i].command, property: "useLargeArc", file: file, line: line)
        try compareProperties(expected[i].useSweep, received[i].useSweep, in: received[i].command, property: "useSweep", file: file, line: line)
    }
}

func compareProperties<T:Equatable>(_ expected: T?, _ received: T?, in command: Command, property: String, file: StaticString = #filePath, line: UInt = #line) throws {
    guard let expected = expected else { return }
    
    let result = try XCTUnwrap(received, "Expected \(property) but got nil")
    XCTAssertEqual(expected, received, "Expected \(command) \(property): \(expected), but got: \(result)", file: file, line: line)
}
