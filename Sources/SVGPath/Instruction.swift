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
    private var digits: [Float] = []
    var isFull: Bool { digits.count == 2 }
    var cgvalue: CGPoint { CGPoint(x: CGFloat(digits[0]), y: CGFloat(digits[1])) }
    
    func clear() {
        digits = []
    }
    
    func addDigit(_ digit: String) {
        if let value = Float(digit) {
            digits.append(value)
        }
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
    
    private var digitAcumulator: String = ""
    private var currentPoint = Point()
    public func addDigit(_ digit: String.Element) {
        
        digitAcumulator.append(digit)
    }
    
    public func processSeparator() {
        if !digitAcumulator.isEmpty {
            currentPoint.addDigit(digitAcumulator)
            digitAcumulator = ""
        }
        
        if currentPoint.isFull {
            point = currentPoint.cgvalue
            currentPoint.clear()
        }
    }
    var lastCharWasExponential: Bool { false }
    var isExpectingNumeric: Bool { !digitAcumulator.isEmpty }
    var hasCoordinate: Bool { point != nil }
}

extension Instruction: Equatable {
    static func == (lhs: Instruction, rhs: Instruction) -> Bool {
        lhs.point == rhs.point &&
            lhs.command == rhs.command &&
            lhs.correlation == rhs.correlation
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
                target.digitAcumulator = x
                target.processSeparator()
                target.digitAcumulator = y
                target.processSeparator()
            }

            
            var digitAcumulator:String { target.digitAcumulator }
        }
        
    }
#endif
