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
    private(set) var points: [CGPoint] = []
    private(set) var command: SVG.Command
    private(set) var correlation: SVG.Correlation
    
    //MARK: - Initializers
    public convenience init () {
        self.init(command: SVG.Command.closePath, correlation: SVG.Correlation.relative)
    }
    
    public init (command: SVG.Command, correlation: SVG.Correlation) {
        self.command = command
        self.correlation = correlation
    }
    
    //MARK: - Mutators
    
    private var previousNumber: Float?
    public func addNumber(number: Float?) {
        guard let number = number else { return }
        
        if previousNumber == nil {
            previousNumber = number
        } else {
            let point = CGPoint(x: CGFloat(previousNumber!), y: CGFloat(number))
            points.append(point)
            previousNumber = nil
        }
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

            var previousNumber: Float? { target.previousNumber }
        }
    }
#endif
