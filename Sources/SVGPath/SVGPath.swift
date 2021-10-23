
import Foundation

private let numericExpression = "0123456789eE"
private let separator = ", \t\n\r"
private let commands = "MmZzLlHhVvCcSsQqTtAa"
private let sign = "+-"
private let exponent = "eE"
private let period: Character = "."

enum Error: Swift.Error {
    case Invalid(String)
}

private extension String.Element {
    func `is`(_ string: String) -> Bool {
        string.contains(self)
    }

    func `is`(_ character: String.Element) -> Bool {
        self == character
    }
}

class SVGPath {
    private var lastRelevantCommand: Command?
    private(set) var instructions: [Instruction]

    init(_ path: String) throws {
        instructions = []

        for char in path {
            if char.is(numericExpression) {
                if instruction.hasCoordinate {
                    switch lastRelevantCommand {
                    case .moveTo:
                        instructions.append(Instruction(.lineTo, correlation: instruction.nextInstructionCorrelation ?? instruction.correlation))
                    case .lineTo:
                        instructions.append(Instruction(.lineTo, correlation: instruction.correlation))
                    case .horizontalLineTo:
                        let newInstruction = Instruction(.horizontalLineTo, correlation: instruction.correlation)
                        newInstruction.add(y: instruction.endPoint!.y)
                        instructions.append(newInstruction)
                    default:
                        print("Missing implementation for: \(char)")
                    }
                }

                instruction.addDigit(char)
            } else if char.is(separator) {
                instruction.processSeparator()
            } else if char.is(commands) {
                lastInstruction?.processSeparator()

                guard let command = Command(rawValue: Character(char.uppercased())) else { return }

                switch command {
                case .closePath:
                    instructions.append(try closePath())
                case .horizontalLineTo, .verticalLineTo:
                    if instructions.isEmpty {
                        throw Error.Invalid("Cannot create an horizontal or vertical line without a previous instruction")
                    }

                    instructions.append(try line(command, correlation: correlation(from: char)))
                case .moveTo:
                    instructions.append(moveTo(correlation: correlation(from: char)))
                case .cubicBezierSmoothCurveTo:
                    instructions.append(try cubicBezierSmoothCurveTo(correlation: correlation(from: char)))
                case .quadraticBezierSmoothCurveTo:
                    instructions.append(try quadraticBezierSmoothCurveTo(correlation: correlation(from: char)))
                default:
                    instructions.append(Instruction(command, correlation: correlation(from: char)))
                }

                switch command {
                case .cubicBezierSmoothCurveTo, .horizontalLineTo, .lineTo, .moveTo, .verticalLineTo:
                    lastRelevantCommand = command
                default:
                    lastRelevantCommand = nil
                }

            } else if char.is(period) {
                if instruction.isExpectingNumeric, instruction.hasDecimalSeparator {
                    instruction.processSeparator()
                }

                if !instruction.isExpectingNumeric {
                    instruction.addDigit("0")
                }
                instruction.addDigit(char)
            } else if char.is(sign) {
                if instruction.hasCoordinate {
                    if lastRelevantCommand == .moveTo || lastRelevantCommand == .lineTo {
                        let newInstruction = Instruction(.lineTo, correlation: instruction.correlation)
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

    private func line(_ command: Command, correlation: Correlation) throws -> Instruction {
        let previousInstruction = instruction
        let instruction = Instruction(command, correlation: correlation)

        switch command {
        case .horizontalLineTo:
            guard let previousY = previousInstruction.endPoint?.y else {
                throw Error.Invalid("Previous instruction should have and end point. None was found.")
            }
            instruction.add(y: previousY)
        case .verticalLineTo:
            guard let previousX = previousInstruction.endPoint?.x else {
                throw Error.Invalid("Previous instruction should have and end point. None was found.")
            }
            instruction.add(x: previousX)
        default:
            break
        }

        return instruction
    }

    private var lastInstruction: Instruction? { instructions.last }

    private var instruction: Instruction {
        guard let instruction = instructions.last else {
            fatalError("You should call instruction only with a valid path")
        }

        return instruction
    }

    private func closePath() throws -> Instruction {
        // Current support is just for one subpath
        guard let initial = instructions.first?.endPoint else {
            throw Error.Invalid("Initial instruction does not have end point.")
        }

        guard let correlation = instructions.last?.correlation else {
            throw Error.Invalid("Last instruction should exist.")
        }

        return Instruction(.lineTo, correlation: correlation, point: initial)
    }

    private func moveTo(correlation: Correlation) -> Instruction {
        if instructions.isEmpty {
            return Instruction(.moveTo, correlation: .absolute, next: correlation)
        } else {
            return Instruction(.moveTo, correlation: correlation)
        }
    }

    private func quadraticBezierSmoothCurveTo(correlation: Correlation) throws -> Instruction {
        guard let currentPoint = instruction.endPoint else {
            throw Error.Invalid("The instruction before a Smooth Quadratic Bezier should have and end point.")
        }

        var control = CGPoint.zero
        if instruction.command == .quadraticBezierCurveTo || instruction.command == .quadraticBezierSmoothCurveTo {
            guard let previousControlPoint = instruction.control1 else {
                throw Error.Invalid("The previous instruction seems to be a Quadratic Bezier, it must have a Control point, but could not find it.")
            }
            control = previousControlPoint
        } else {
            control = currentPoint
        }

        return Instruction(.quadraticBezierSmoothCurveTo,
                           correlation: correlation,
                           control: Helper.reflect(current: currentPoint, previousControl: control))
    }

    private func cubicBezierSmoothCurveTo(correlation: Correlation) throws -> Instruction {
        guard let currentPoint = instruction.endPoint else {
            throw Error.Invalid("The instruction before a Smooth Cubic Bezier should have an end point.")
        }

        var control = CGPoint.zero
        if instruction.command == .cubicBezierCurveTo || instruction.command == .cubicBezierSmoothCurveTo {
            guard let previousControlPoint = instruction.control2 else {
                throw Error.Invalid("The previous instruction seems to be a Cubic Bezier, it must have a Control point, but could not find it.")
            }
            control = previousControlPoint
        } else {
            control = currentPoint
        }

        return Instruction(.cubicBezierSmoothCurveTo,
                           correlation: correlation,
                           control: Helper.reflect(current: currentPoint, previousControl: control))
    }

    private func correlation(from char: String.Element) -> Correlation {
        char.isUppercase ? .absolute : .relative
    }
}
