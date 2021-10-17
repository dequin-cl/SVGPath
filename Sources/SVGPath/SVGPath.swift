
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

        for char in path {
            if digitExp.contains(char) {
                if instruction.hasCoordinate {
                    switch lastRelevantCommand {
                    case .moveTo, .lineTo:
                        instructions.append(Instruction(command: .lineTo, correlation: instruction.correlation))
                    case .horizontalLineTo:
                        let newInstruction = Instruction(command: .horizontalLineTo, correlation: instruction.correlation)
                        newInstruction.add(y: instruction.point!.y)
                        instructions.append(newInstruction)
                    default:
                        print("Missing implementation")
                    }
                }

                instruction.addDigit(char)
            } else if separator.contains(char) {
                instruction.processSeparator()
            } else if drawToCommands.contains(char) {
                lastInstruction?.processSeparator()

                guard let command = SVG.Command(rawValue: Character(char.uppercased())) else { return }

                switch command {
                case .closePath:
                    addLineBetweenInitialAndLastPoint()
                    return
                case .horizontalLineTo:
                    if instructions.isEmpty { return }

                    let correlation: SVG.Correlation = char.isUppercase ? .absolute : .relative
                    addHorizontalInstruction(correlation: correlation)
                    lastRelevantCommand = .horizontalLineTo
                case .verticalLineTo:
                    if instructions.isEmpty { return }
                    
                    let correlation: SVG.Correlation = char.isUppercase ? .absolute : .relative
                    addVerticalInstruction(correlation: correlation)
                    lastRelevantCommand = .verticalLineTo
                default:
                    let correlation: SVG.Correlation = char.isUppercase ? .absolute : .relative
                    instructions.append(Instruction(command: command, correlation: correlation))
                    switch command {
                    case .moveTo:
                        lastRelevantCommand = .moveTo
                    case .lineTo:
                        lastRelevantCommand = .lineTo
                    default:
                        lastRelevantCommand = nil
                    }
                }

            } else if char == period, instruction.isExpectingNumeric {
                instruction.addDigit(char)
            } else if sign.contains(char) {
                if instruction.hasCoordinate {
                    if lastRelevantCommand == .moveTo || lastRelevantCommand == .lineTo {
                        let newInstruction = Instruction(command: .lineTo, correlation: instruction.correlation)
                        instructions.append(newInstruction)
                    }
                }

                instruction.addDigit(char)
            }
        }
        instruction.processSeparator()
    }

    private func addHorizontalInstruction(correlation: SVG.Correlation) {
        guard let previousY = instruction.point?.y else { return }

        let horizontal = Instruction(command: .horizontalLineTo, correlation: correlation)
        horizontal.add(y: previousY)

        instructions.append(horizontal)
    }
    
    private func addVerticalInstruction(correlation: SVG.Correlation) {
        guard let previousX = instruction.point?.x else { return }
        
        let vertical = Instruction(command: .verticalLineTo, correlation: correlation)
        vertical.add(x: previousX)
        instructions.append(vertical)
    }

    private var lastInstruction: Instruction? { instructions.last }

    private var instruction: Instruction {
        guard let instruction = instructions.last else {
            fatalError("You should call instruction only with a valid path")
        }

        return instruction
    }

    private func addLineBetweenInitialAndLastPoint() {
        // Current support is just for one subpath
        guard let initial = instructions.first?.point,
              let correlation = instructions.first?.correlation
        else {
            return
        }

        instructions.append(Instruction(command: .lineTo, correlation: correlation, point: initial))
    }
}
