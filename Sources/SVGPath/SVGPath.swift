
import Foundation

let digit = "0123456789eE"
let separator = ", \t\n\r"
let drawToCommands = "MmZzLlHhVvCcSsQqTtAa"
let sign = "+-"
let exponent = "eE"
let period: Character = "."

class SVGPath {
    private(set) var instructions: [Instruction]

    init(_ path: String) {
        
        instructions = []
        
        path.forEach { char in
            
            if digit.contains(char) {
                
                if instruction != nil, instruction!.hasCoordinate {
                    
                    if instruction?.command == .moveTo {
                        let newInstrution = Instruction(command: .lineTo, correlation: instruction!.correlation)
                        instructions.append(newInstrution)
                    }
                }
                
                instruction?.addDigit(char)
            } else if separator.contains(char) {
                instruction?.processSeparator()
            } else if drawToCommands.contains(char) {
                let correlation: SVG.Correlation = char.isUppercase ? .absolute: .relative
                guard let command = SVG.Command(rawValue: Character(char.uppercased())) else {
                    return
                }
                
                instructions.append(Instruction(command: command, correlation: correlation))
            } else if char == period && (instruction?.isExpectingNumeric ?? false) {
                instruction?.addDigit(char)
            }
        }
        instruction?.processSeparator()
    }
    
    private var instruction: Instruction? { instructions.last }
}
