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
                    self.move(to: instruction.endPoint!)
                case .horizontalLineTo, .lineTo:
                    self.addLine(to: instruction.endPoint!)
                default:
                    break
                }
            }
        }
    }
#endif
