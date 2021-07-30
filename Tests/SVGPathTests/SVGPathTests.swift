    import XCTest
    @testable import SVGPath

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

            XCTAssertEqual(instruction.testHooks.digitAcumulator, "1")
            instruction.processSeparator()
            
            XCTAssertNil(instruction.point)

            instruction.addDigit("2")

            XCTAssertEqual(instruction.testHooks.digitAcumulator, "2")
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

            XCTAssertEqual(instruction.testHooks.digitAcumulator, "100")
            instruction.processSeparator()
            
            XCTAssertNil(instruction.point)

            instruction.addDigit("2")
            instruction.addDigit("0")

            XCTAssertEqual(instruction.testHooks.digitAcumulator, "20")
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

            XCTAssertEqual(instruction.testHooks.digitAcumulator, "-100")
            instruction.processSeparator()
            
            XCTAssertNil(instruction.point)

            instruction.addDigit("2")
            instruction.addDigit("0")
            instruction.addDigit(".")
            instruction.addDigit("5")

            XCTAssertEqual(instruction.testHooks.digitAcumulator, "20.5")
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
            
            XCTAssertEqual(instruction.testHooks.digitAcumulator, "11.5")
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
        
        
        
//        func testMultipleMoveToSameCommand() {
//            SVGPath("M1 2 3 4").instructions
////        let actual:[SVGCommand] = SVGPath("M1 2 3 4").commands
////        let expect:[SVGCommand] = [
////            SVGCommand(1.0, 2.0, type: .move),
////            SVGCommand(3.0, 4.0, type: .move)
////        ]
////
////        assertCommandsEqual(actual, expect)
//        }
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
