import Foundation

typealias Command = SVG.Command
typealias Correlation = SVG.Correlation

enum SVG {
    enum Correlation {
        case absolute
        case relative
    }

    enum Command: Character {
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

    private(set) var radius: CGPoint?
    private(set) var rotation: Int?
    private(set) var useLargeArc: Bool?
    private(set) var useSweep: Bool?

    private(set) var command: Command
    private(set) var correlation: Correlation
    private(set) var nextInstructionCorrelation: Correlation?

    private var digitAccumulator: String = ""
    private var currentPoint = Point()

    var lastCharWasExponential: Bool { digitAccumulator.last?.lowercased() == "e" }
    var isExpectingNumeric: Bool { !digitAccumulator.isEmpty }
    var hasDecimalSeparator: Bool { digitAccumulator.contains(".") }
    var hasCoordinate: Bool { endPoint != nil }

    // MARK: - Initializers

    public init(_ command: Command, correlation: Correlation) {
        self.command = command
        self.correlation = correlation
    }

    public convenience init() {
        self.init(.closePath, correlation: .relative)
    }

    public convenience init(_ command: Command, correlation: Correlation, control: CGPoint) {
        self.init(command, correlation: correlation)
        control1 = control
    }

    public convenience init(_ command: Command, correlation: Correlation, point: CGPoint) {
        self.init(command, correlation: correlation)

        if command == .cubicBezierSmoothCurveTo {
            control1 = point
        } else {
            endPoint = point
        }
    }

    public convenience init(_ command: Command, correlation: Correlation, next nextInstructionCorrelation: Correlation) {
        self.init(command, correlation: correlation)
        self.nextInstructionCorrelation = nextInstructionCorrelation
    }

    func addDigit(_ digit: Char) {
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
            if command == .ellipticalArc {
                if radius == nil {
                    currentPoint.addValue(digitAccumulator)
                } else if rotation == nil {
                    if let number = formatter.number(from: digitAccumulator) {
                        rotation = Int(truncating: number)
                    }
                } else if useLargeArc == nil {
                    if let number = formatter.number(from: digitAccumulator) {
                        useLargeArc = Bool(truncating: number)
                    }
                } else if useSweep == nil {
                    if let number = formatter.number(from: digitAccumulator) {
                        useSweep = Bool(truncating: number)
                    }
                } else {
                    currentPoint.addValue(digitAccumulator)
                }
                digitAccumulator = ""
            } else {
                currentPoint.addValue(digitAccumulator)
                digitAccumulator = ""
            }
        }

        if let point = currentPoint.cgValue {
            currentPoint.clear()

            switch command {
            case .cubicBezierCurveTo:
                if control1 == nil {
                    control1 = point
                } else if control2 == nil {
                    control2 = point
                } else {
                    endPoint = point
                }
            case .cubicBezierSmoothCurveTo:
                if control2 == nil {
                    control2 = point
                } else {
                    endPoint = point
                }
            case .quadraticBezierCurveTo:
                if control1 == nil {
                    control1 = point
                } else {
                    endPoint = point
                }
            case .ellipticalArc:
                if radius == nil {
                    radius = point
                } else {
                    endPoint = point
                }
            default:
                endPoint = point
            }
        }
    }
}

// MARK: - For better debugging

extension Instruction: CustomStringConvertible {
    var description: String {
        let cmd = correlation == .relative ? command.rawValue.lowercased() : command.rawValue.uppercased()
        var description = ""
        description += "\(cmd)"
        description += endPoint?.debugDescription ?? ""

        if command == .ellipticalArc {
            description += " rotation: \(rotation ?? -1) "
            if let useLargeArc = useLargeArc {
                description += " largeArc: \(useLargeArc)"
            } else {
                description += " largeArc: Not defined!"
            }
            if let useSweep = useSweep {
                description += " sweep: \(useSweep)"
            } else {
                description += " sweep: Not defined!"
            }
        }

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
    var cgValue: CGPoint? {
        guard let coordinateX = coordinateX, let coordinateY = coordinateY else {
            return nil
        }

        return CGPoint(x: coordinateX, y: coordinateY)
    }

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

            func addRadius(x: CGFloat, y: CGFloat) {
                target.radius = CGPoint(x: x, y: y)
            }

            func addRotation(degrees: Int) {
                target.rotation = degrees
            }

            func useLargeArc(_ use: Bool) {
                target.useLargeArc = use
            }

            func useSweep(_ use: Bool) {
                target.useSweep = use
            }
        }
    }
#endif
