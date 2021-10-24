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
                    addCurve(to: instruction.endPoint!, controlPoint1: instruction.control1!, controlPoint2: instruction.control2!)
                case .quadraticBezierCurveTo, .quadraticBezierSmoothCurveTo:
                    addQuadCurve(to: instruction.endPoint!, controlPoint: instruction.control1!)
                case .ellipticalArc:
                    let radius = CGPointDistance(from: instruction.endPoint!, to: instruction.radius!)
                    addArc(withCenter: instruction.endPoint!, radius: radius, startAngle: instruction.rotation!, endAngle: 360, clockwise: true)
                default:
                    break
                }
            }
        }
    }
#endif

import CoreGraphics
func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
    return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
}

func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
    return sqrt(CGPointDistanceSquared(from: from, to: to))
}
