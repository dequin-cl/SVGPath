import XCTest
@testable import SVGPath

func SVGAssertEqual (_ expected:[Instruction], _ received:[Instruction], file : StaticString = #filePath, line : UInt = #line) throws {
    
    guard !expected.isEmpty, !received.isEmpty else {
        XCTFail("Empty instructions", file: file, line: line)
        return
    }
    
    XCTAssertEqual(expected.count, received.count, "Number of instructions should be the same. Expected: \(expected) but received: \(received)", file: file, line: line)
    
    guard expected.count == received.count else { return }
    
    for i in 0 ..< expected.count {
        XCTAssertEqual(expected[i].command, received[i].command, "command should be the same", file: file, line: line)
        XCTAssertEqual(expected[i].correlation, received[i].correlation, "correlation should be the same", file: file, line: line)
        
        XCTAssertEqual(expected[i].point, received[i].point, "point should be the same. Expected: \(expected) but received: \(received)", file: file, line: line)
        
//        XCTAssertEqual(a[i].point,    b[i].point,    "points should be the same", file: file, line: line)
//        XCTAssertEqual(a[i].control1, b[i].control1, "control point 1 should be the same", file: file, line: line)
//        XCTAssertEqual(a[i].control2, b[i].control2, "control point 2 should be the same", file: file, line: line)
    }
}
