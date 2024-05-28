//
//  CIImage + Extensions.swift
//  FaceDetector
//
//  Created by Sevak Tadevosyan on 24.05.24.
//

import Foundation
import CoreImage
import UIKit

extension CIImage {
    var toCGImage: CGImage? {
        let context = CIContext(options: nil)
        return context.createCGImage(self, from: self.extent)
    }
    
    func boundingBox(toFace boundingBox: CGRect) -> CGImage? {
        let percentage = 0.2
        let width = boundingBox.width * extent.width
        let height = boundingBox.height * extent.height
        let x = boundingBox.minX * extent.width
        let y = (1 - boundingBox.minY) * extent.height - height
        let context = CIContext()
        let rect = CGRect(x: x, y: y,
                          width: width,
                          height: height).insetBy(dx: -width * percentage, dy: -height * percentage)
        let croppedImage = context.createCGImage(self, from: rect)
        return croppedImage
    }
    
    func cropFaceContour(points: [CGPoint]) -> CGImage? {
        let path = CGPath.pathFrom(points: convexHull(points))
        let uiImage = UIImage(ciImage: self)
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = uiImage.scale
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: uiImage.size, format: format)
        
        let croppedImage = renderer.image { context in
            context.cgContext.addPath(path)
            context.cgContext.clip()
            uiImage.draw(at: .zero)
        }
        return croppedImage.cgImage
    }
}
