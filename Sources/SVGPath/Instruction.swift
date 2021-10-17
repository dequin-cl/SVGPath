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
        if let float = Float(digit) {
            if coordinateX == nil {
                add(x: CGFloat(float))
            } else {
                add(y: CGFloat(float))
            }
        }
    }
    
    func add(x:CGFloat) {
        coordinateX = x
    }

    func add(y:CGFloat) {
        coordinateY = y
    }

}

class Instruction {
    
    private(set) var point: CGPoint?
    private(set) var command: SVG.Command
    private(set) var correlation: SVG.Correlation
    
    //MARK: - Initializers
    public convenience init () {
        self.init(command: SVG.Command.closePath, correlation: SVG.Correlation.relative)
    }
    
    public init (command: SVG.Command, correlation: SVG.Correlation, point: CGPoint? = nil) {
        self.command = command
        self.correlation = correlation
        self.point = point
    }
    
    private var digitAccumulator: String = ""
    private var currentPoint = Point()
    func addDigit(_ digit: String.Element) {
        
        digitAccumulator.append(digit)
    }
    
    func add(x:CGFloat) {
        currentPoint.add(x: x)
    }

    func add(y:CGFloat) {
        currentPoint.add(y: y)
    }

    func processSeparator() {
        if !digitAccumulator.isEmpty {
            currentPoint.addValue(digitAccumulator)
            digitAccumulator = ""
        }
        
        if currentPoint.isFull {
            point = currentPoint.cgValue
            currentPoint.clear()
        }
    }
    var lastCharWasExponential: Bool { false }
    var isExpectingNumeric: Bool { !digitAccumulator.isEmpty }
    var hasCoordinate: Bool { point != nil }
}

extension Instruction: Equatable {
    static func == (lhs: Instruction, rhs: Instruction) -> Bool {
        lhs.point == rhs.point &&
            lhs.command == rhs.command &&
            lhs.correlation == rhs.correlation
    }
}

extension Instruction: CustomStringConvertible {
    var description: String {
        var description = ""
        description += "\(command.rawValue)"
        description += point?.debugDescription ?? ""
        return description
    }
}

// MARK: - CGPoint helpers

//private func +(a:CGPoint, b:CGPoint) -> CGPoint {
//    return CGPoint(x: a.x + b.x, y: a.y + b.y)
//}

//private func -(a:CGPoint, b:CGPoint) -> CGPoint {
//    return CGPoint(x: a.x - b.x, y: a.y - b.y)
//}


// MARK: - TestHooks

#if DEBUG
    extension Instruction {
        var testHooks: TestHooks {
            return TestHooks(target: self)
        }

        struct TestHooks {
            let target: Instruction

            fileprivate init(target: Instruction) {
                self.target = target
            }
            
            func addPoint(x: CGFloat, y: CGFloat) {
                target.point = CGPoint(x: x, y: y)
            }

            func addPoint(x: String, y: String) {
                target.digitAccumulator = x
                target.processSeparator()
                target.digitAccumulator = y
                target.processSeparator()
            }

            
            var digitAccumulator:String { target.digitAccumulator }
        }
        
    }
#endif
