
import Foundation

let digitExp = "0123456789eE"
let separator = ", \t\n\r"
let drawToCommands = "MmZzLlHhVvCcSsQqTtAa"
let sign = "+-"
let exponent = "eE"
let period: Character = "."

class SVGPath {
    private(set) var instructions: [Instruction]
    private var lastRelevantCommand: SVG.Command?
    init(_ path: String) {
        
        instructions = []
        
        path.forEach { char in
            
            if digitExp.contains(char) {
                
                if instruction.hasCoordinate {
                    
                    if lastRelevantCommand == .moveTo || lastRelevantCommand == .lineTo {
                        let newInstrution = Instruction(command: .lineTo, correlation: instruction.correlation)
                        instructions.append(newInstrution)
                    }
                }
                
                instruction.addDigit(char)
            } else if separator.contains(char) {
                instruction.processSeparator()
            } else if drawToCommands.contains(char) {
                lastInstrution?.processSeparator()
                
                let correlation: SVG.Correlation = char.isUppercase ? .absolute: .relative
                guard let command = SVG.Command(rawValue: Character(char.uppercased())) else {
                    return
                }
                
                if command == .closePath {
                    addLineBetweenInitialAndLastPoint()
                    return
                }
                
                instructions.append(Instruction(command: command, correlation: correlation))
                if command == .moveTo {
                    lastRelevantCommand = .moveTo
                } else if command == .lineTo {
                    lastRelevantCommand = .lineTo
                } else {
                    lastRelevantCommand = nil
                }
            } else if char == period && instruction.isExpectingNumeric {
                instruction.addDigit(char)
            } else if sign.contains(char) {
                if instruction.hasCoordinate {
                    if lastRelevantCommand == .moveTo || lastRelevantCommand == .lineTo {
                        let newInstrution = Instruction(command: .lineTo, correlation: instruction.correlation)
                        instructions.append(newInstrution)
                    }
                }

                instruction.addDigit(char)
            }
        }
        instruction.processSeparator()
    }
    
    private var lastInstrution: Instruction? { instructions.last }
    
    private var instruction: Instruction {
        guard let instruction = instructions.last else {
            fatalError("You should call instruction only with a valid path")
        }
        
        return instruction
    }
    
    private func addLineBetweenInitialAndLastPoint() {
        // Current support is just for one subpath
        guard let initial = instructions.first?.point,
              let correlation = instructions.first?.correlation else {
            return
        }
        
        instructions.append(Instruction(command: .lineTo, correlation: correlation, point: initial))
    }
}
