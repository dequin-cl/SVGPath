
import Foundation

let digit = "0123456789eE"
let separator = ", \t\n\r"
let drawToCommands = "MmZzLlHhVvCcSsQqTtAa"
let sign = "+-"
let exponent = "eE"
let period: Character = "."

class SVGPath {
    private(set) var entities: [String]
    private(set) var instructions: [Instruction]

    init(_ path: String) {
        var isFloat = false
        var entity = ""
        entities = []
        instructions = []
        var instruction: Instruction!
        
        path.forEach { char in
            
            if drawToCommands.contains(char) {
                let correlation: SVG.Correlation = char.isUppercase ? .absolute: .relative
                guard let command = SVG.Command(rawValue: char) else {
                    return
                }
                
                instruction = Instruction(command: command, correlation: correlation)
                
                instructions.append(instruction)
            } else if digit.contains(char) {
                instruction.addNumber(number:Float(String(char)))
                entity.append(char)
            } else if char == period {
                if isFloat {
                    instruction.addNumber(number: Float(entity))
                    entity = String(char)
                } else {
                    isFloat = true
                    entity.append(char)
                }
            }
        }

        print(entities)
    }
    

}
