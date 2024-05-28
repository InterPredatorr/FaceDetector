//
//  CGPath + Extensions.swift
//  FaceDetector
//
//  Created by Sevak Tadevosyan on 25.05.24.
//

import Foundation
import CoreGraphics


extension CGPath {
    static func pathFrom(points: [CGPoint]) -> CGPath {
        let path = CGMutablePath()
        if let firstPoint = points.first {
            path.move(to: firstPoint)
            points.dropFirst().forEach { path.addLine(to: $0) }
            path.closeSubpath()
        }
        return path
    }
}
