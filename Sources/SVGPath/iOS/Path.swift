//
// Copyright © 2021 dequin_cl. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13.0, *)
extension Path {
    init(_ instructions: [Instruction]) {
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
                let radius = CGPointDistance(from: instruction.endPoint!, to: instruction.radius!)

                addArc(center: instruction.endPoint!, radius: radius, startAngle: Angle(degrees: instruction.rotation!), endAngle: Angle(degrees: 360), clockwise: true)
            default:
                break
            }
        }
    }
}
#endif
