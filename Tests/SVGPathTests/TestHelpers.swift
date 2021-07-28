import XCTest
@testable import SVGPath

func SVGAssertEqual (_ a:[Instruction], _ b:[Instruction], file : StaticString = #filePath, line : UInt = #line) throws {
    
    guard !a.isEmpty, !b.isEmpty else {
        XCTFail("Empty instructions", file: file, line: line)
        return
    }
    
    XCTAssertEqual(a.count, b.count, "Number of instructions should be the same", file: file, line: line)
    
    guard a.count == b.count else { return }
    
    for i in 0 ..< a.count {
        XCTAssertEqual(a[i].command, b[i].command, "command should be the same", file: file, line: line)
        XCTAssertEqual(a[i].correlation, b[i].correlation, "correlation should be the same", file: file, line: line)
        
        XCTAssertEqual(a[i].point, b[i].point, "point should be the same", file: file, line: line)
        
//        XCTAssertEqual(a[i].point,    b[i].point,    "points should be the same", file: file, line: line)
//        XCTAssertEqual(a[i].control1, b[i].control1, "control point 1 should be the same", file: file, line: line)
//        XCTAssertEqual(a[i].control2, b[i].control2, "control point 2 should be the same", file: file, line: line)
    }
}
