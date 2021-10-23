
import Foundation

let digitExp = "0123456789eE"
let separator = ", \t\n\r"
let drawToCommands = "MmZzLlHhVvCcSsQqTtAa"
let sign = "+-"
let exponent = "eE"
let period: Character = "."

enum Error: Swift.Error {
    case Invalid(String)
}

class SVGPath {
    private(set) var instructions: [Instruction]
    private var lastRelevantCommand: SVG.Command?
    init(_ path: String) throws {
        instructions = []

        for char in path {
            if digitExp.contains(char) {
                if instruction.hasCoordinate {
                    switch lastRelevantCommand {
                    case .moveTo:
                        instructions.append(Instruction(command: .lineTo, correlation: instruction.nextInstructionCorrelation ?? instruction.correlation))
                    case .lineTo:
                        instructions.append(Instruction(command: .lineTo, correlation: instruction.correlation))
                    case .horizontalLineTo:
                        let newInstruction = Instruction(command: .horizontalLineTo, correlation: instruction.correlation)
                        newInstruction.add(y: instruction.endPoint!.y)
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
                case .horizontalLineTo, .verticalLineTo:
                    if instructions.isEmpty { return }

                    add(command: command, char: char)
                    lastRelevantCommand = command
                case .moveTo:
                    let correlation: SVG.Correlation = char.isUppercase ? .absolute : .relative

                    if instructions.isEmpty {
                        instructions.append(Instruction(command: command, correlation: .absolute, next: correlation))
                    } else {
                        instructions.append(Instruction(command: command, correlation: correlation))
                    }

                    lastRelevantCommand = .moveTo
                case .cubicBezierSmoothCurveTo:
                    guard let currentPoint = instruction.endPoint else {
                        throw Error.Invalid("The instruction before a Smooth Cubic Bezier should have and end point.")
                    }
                    let correlation: SVG.Correlation = char.isUppercase ? .absolute : .relative

                    let newInstruction = Instruction(command: command, correlation: correlation, point: currentPoint)
                    instructions.append(newInstruction)
                    lastRelevantCommand = .cubicBezierSmoothCurveTo
                case .quadraticBezierSmoothCurveTo:
                    guard let currentPoint = instruction.endPoint else {
                        throw Error.Invalid("The instruction before a Smooth Quadratic Bezier should have and end point.")
                    }
                    let correlation: SVG.Correlation = char.isUppercase ? .absolute : .relative

//                    if previous instruction.control1
                    // else

                    var control = CGPoint.zero

                    if instruction.command == .quadraticBezierCurveTo || instruction.command == .quadraticBezierSmoothCurveTo {
                        guard let previousControlPoint = instruction.control1 else {
                            throw Error.Invalid("The previous instruction seems to be a Quadratic Bezier, it must have a Control point, but could not find it.")
                        }
                        control = previousControlPoint
                    } else {
                        control = currentPoint
                    }

                    let newInstruction = Instruction(command: command, correlation: correlation, control: Helper.reflect(current: currentPoint, previousControl: control))

                    instructions.append(newInstruction)
                default:
                    let correlation: SVG.Correlation = char.isUppercase ? .absolute : .relative
                    instructions.append(Instruction(command: command, correlation: correlation))
                    switch command {
                    case .lineTo:
                        lastRelevantCommand = .lineTo
                    default:
                        lastRelevantCommand = nil
                    }
                }

            } else if char == period {
                if instruction.isExpectingNumeric, instruction.hasDecimalSeparator {
                    instruction.processSeparator()
                }

                if !instruction.isExpectingNumeric {
                    instruction.addDigit("0")
                }
                instruction.addDigit(char)
            } else if sign.contains(char) {
                if instruction.hasCoordinate {
                    if lastRelevantCommand == .moveTo || lastRelevantCommand == .lineTo {
                        let newInstruction = Instruction(command: .lineTo, correlation: instruction.correlation)
                        instructions.append(newInstruction)
                    }
                }

                if instruction.isExpectingNumeric, !instruction.lastCharWasExponential {
                    instruction.processSeparator()
                }

                instruction.addDigit(char)
            }
        }
        instruction.processSeparator()
    }

    private func add(command: SVG.Command, char: String.Element) {
        let correlation: SVG.Correlation = char.isUppercase ? .absolute : .relative
        let newInstruction = Instruction(command: command, correlation: correlation)

        switch command {
        case .horizontalLineTo:
            guard let previousY = instruction.endPoint?.y else { return }
            newInstruction.add(y: previousY)
        case .verticalLineTo:
            guard let previousX = instruction.endPoint?.x else { return }
            newInstruction.add(x: previousX)
        default: return
        }

        instructions.append(newInstruction)
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
        guard let initial = instructions.first?.endPoint,
              let correlation = instructions.last?.correlation
        else {
            return
        }

        instructions.append(Instruction(command: .lineTo, correlation: correlation, point: initial))
    }
}
