    import XCTest
    @testable import SVGPath

    final class SVGPathTests: XCTestCase {
        
        func testBuildClosePathInstruction() {
            let instruction = Instruction()
            XCTAssertEqual(instruction.command, .closePath)
            XCTAssertEqual(instruction.correlation, .relative)
            XCTAssertTrue(instruction.points.isEmpty)
//            XCTAssertEqual(instruction.point, .zero)
//            XCTAssertEqual(instruction.control1, .zero)
//            XCTAssertEqual(instruction.control2, .zero)
        }
        
        func testBuildAbsoluteMoveToInstruction() {
            let instruction = Instruction(command: .moveTo, correlation: .absolute)
            
            XCTAssertEqual(instruction.correlation, .absolute)
            XCTAssertNil(instruction.testHooks.previousNumber)
            XCTAssertTrue(instruction.points.isEmpty)

            instruction.addNumber(number: 1.0)
            
            XCTAssertEqual(instruction.testHooks.previousNumber, 1.0)
            XCTAssertTrue(instruction.points.isEmpty)

            instruction.addNumber(number: 2.0)

            XCTAssertNil(instruction.testHooks.previousNumber)
            XCTAssertEqual(instruction.points.count, 1)

        }
        
        func testSingleMoveTo() throws {
            let result = SVGPath("M1 2").instructions
            
            let instruction = Instruction(command: .moveTo, correlation: .absolute)
            instruction.addNumber(number: 1.0)
            instruction.addNumber(number: 2.0)
            let expected = [instruction]
            
            try SVGAssertEqual(expected, result)
        }

        func testMoveToWithLineTo() throws {
            let result = SVGPath("M1 2 3 4").instructions
            
            let instruction = Instruction(command: .moveTo, correlation: .absolute)
            instruction.addNumber(number: 1.0)
            instruction.addNumber(number: 3.0)
            let expected = [instruction]
            
            try SVGAssertEqual(expected, result)
        }
        
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
