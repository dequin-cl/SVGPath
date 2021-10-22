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
            "Expected endPoint: \(expected[i].endPoint!) but received: \(String(describing: received[i].endPoint))",
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
    }
}
