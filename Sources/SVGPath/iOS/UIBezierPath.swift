//
// Copyright © 2021 dequin_cl. All rights reserved.
//

#if os(iOS)
    import UIKit

    extension UIBezierPath {
        convenience init(_ instructions: [Instruction]) {
            self.init()

            instructions.forEach { instruction in
                switch instruction.command {
                case .moveTo:
                    move(to: instruction.endPoint!)
                case .horizontalLineTo, .lineTo, .verticalLineTo:
                    addLine(to: instruction.endPoint!)
                case .cubicBezierCurveTo, .cubicBezierSmoothCurveTo:
                    addCurve(to: instruction.endPoint!, control1: instruction.control1!, control2: instruction.control2!)
                case .quadraticBezierCurveTo, .quadraticBezierSmoothCurveTo:
                    addQuadCurve(to: instruction.endPoint!, control: instruction.control1!)
                case .ellipticalArc:
                    addArc(center: instruction.endPoint!, radius: instruction.radius!, startAngle: instruction.rotation!, endAngle: 360, clockwise: true)
                default:
                    break
                }
            }
        }
    }
#endif
