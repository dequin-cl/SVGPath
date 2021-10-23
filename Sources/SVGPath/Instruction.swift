import Foundation

public enum SVG {
    public enum Correlation {
        case absolute
        case relative
    }

    public enum Command: Character {
        case moveTo = "M"
        case lineTo = "L"
        case horizontalLineTo = "H"
        case verticalLineTo = "V"
        case cubicBezierCurveTo = "C"
        case cubicBezierSmoothCurveTo = "S"
        case ellipticalArc = "A"
        case quadraticBezierCurveTo = "Q"
        case quadraticBezierSmoothCurveTo = "T"
        case closePath = "Z"
    }
}

class Instruction {
    private(set) var endPoint: CGPoint?
    private(set) var control1: CGPoint?
    private(set) var control2: CGPoint?

    private(set) var command: SVG.Command
    private(set) var correlation: SVG.Correlation
    private(set) var nextInstructionCorrelation: SVG.Correlation?

    private var digitAccumulator: String = ""
    private var currentPoint = Point()
    
    var lastCharWasExponential: Bool { digitAccumulator.last?.lowercased() == "e" }
    var isExpectingNumeric: Bool { !digitAccumulator.isEmpty }
    var hasDecimalSeparator: Bool { digitAccumulator.contains(".") }
    var hasCoordinate: Bool { endPoint != nil }
    
    // MARK: - Initializers

    public init(command: SVG.Command, correlation: SVG.Correlation) {
        self.command = command
        self.correlation = correlation
    }

    public convenience init() {
        self.init(command: SVG.Command.closePath, correlation: SVG.Correlation.relative)
    }

    public convenience init(command: SVG.Command, correlation: SVG.Correlation, control: CGPoint) {
        self.init(command: command, correlation: correlation)
        control1 = control
    }

    public convenience init(command: SVG.Command, correlation: SVG.Correlation, point: CGPoint) {
        self.init(command: command, correlation: correlation)

        if command == .cubicBezierSmoothCurveTo {
            control1 = point
        } else {
            endPoint = point
        }
    }

    public convenience init(command: SVG.Command, correlation: SVG.Correlation, next nextInstructionCorrelation: SVG.Correlation) {
        self.init(command: command, correlation: correlation)
        self.nextInstructionCorrelation = nextInstructionCorrelation
    }

    func addDigit(_ digit: String.Element) {
        digitAccumulator.append(digit)
    }

    func add(x: CGFloat) {
        currentPoint.add(x: x)
    }

    func add(y: CGFloat) {
        currentPoint.add(y: y)
    }

    func processSeparator() {
        if !digitAccumulator.isEmpty {
            currentPoint.addValue(digitAccumulator)
            digitAccumulator = ""
        }

        if currentPoint.isFull {
            if command == .cubicBezierCurveTo {
                if control1 == nil {
                    control1 = currentPoint.cgValue
                } else if control2 == nil {
                    control2 = currentPoint.cgValue
                } else {
                    endPoint = currentPoint.cgValue
                }
            } else if command == .cubicBezierSmoothCurveTo {
                if control2 == nil {
                    control2 = currentPoint.cgValue
                } else {
                    endPoint = currentPoint.cgValue
                }
            } else if command == .quadraticBezierCurveTo {
                if control1 == nil {
                    control1 = currentPoint.cgValue
                } else {
                    endPoint = currentPoint.cgValue
                }
            } else {
                endPoint = currentPoint.cgValue
            }

            currentPoint.clear()
        }
    }
}

// MARK: - Equatable

extension Instruction: Equatable {
    static func == (lhs: Instruction, rhs: Instruction) -> Bool {
        lhs.endPoint == rhs.endPoint &&
            lhs.command == rhs.command &&
            lhs.correlation == rhs.correlation
    }
}

// MARK: - For better debugging

extension Instruction: CustomStringConvertible {
    var description: String {
        let command = correlation == .relative ? command.rawValue.lowercased() : command.rawValue.uppercased()
        var description = ""
        description += "\(command)"
        description += endPoint?.debugDescription ?? ""
        return description
    }
}

// MARK: - Private Elements

private var formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.decimalSeparator = "."
    return formatter
}()

private class Point {
    private var coordinateX: CGFloat?
    private var coordinateY: CGFloat?
    var isFull: Bool { coordinateX != nil && coordinateY != nil }
    var cgValue: CGPoint { CGPoint(x: coordinateX!, y: coordinateY!) }

    func clear() {
        coordinateX = nil
        coordinateY = nil
    }

    func addValue(_ digit: String) {
        if let number = formatter.number(from: digit) {
            if coordinateX == nil {
                add(x: CGFloat(truncating: number))
            } else {
                add(y: CGFloat(truncating: number))
            }
        }
    }

    func add(x: CGFloat) {
        coordinateX = x
    }

    func add(y: CGFloat) {
        coordinateY = y
    }
}

// MARK: - CGPoint helpers

// private func +(a:CGPoint, b:CGPoint) -> CGPoint {
//    return CGPoint(x: a.x + b.x, y: a.y + b.y)
// }

// private func -(a:CGPoint, b:CGPoint) -> CGPoint {
//    return CGPoint(x: a.x - b.x, y: a.y - b.y)
// }

// MARK: - TestHooks

#if DEBUG
    extension Instruction {
        var testHooks: TestHooks {
            TestHooks(target: self)
        }

        struct TestHooks {
            let target: Instruction

            fileprivate init(target: Instruction) {
                self.target = target
            }

            func addEndPoint(x: CGFloat, y: CGFloat) {
                target.endPoint = CGPoint(x: x, y: y)
            }

            func addEndPoint(x: String, y: String) {
                target.digitAccumulator = x
                target.processSeparator()
                target.digitAccumulator = y
                target.processSeparator()
            }

            var digitAccumulator: String { target.digitAccumulator }

            func addControl1(x: CGFloat, y: CGFloat) {
                target.control1 = CGPoint(x: x, y: y)
            }

            func addControl2(x: CGFloat, y: CGFloat) {
                target.control2 = CGPoint(x: x, y: y)
            }
        }
    }
#endif
