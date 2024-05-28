//
//  VNFaceLandmarkRegion2D + Extensions.swift
//  FaceDetector
//
//  Created by Sevak Tadevosyan on 25.05.24.
//

import Foundation
import CoreImage
import Vision

extension VNFaceLandmarkRegion2D {
    func toCGPoint(for ciImage: CIImage) -> [CGPoint] {
        self.pointsInImage(imageSize: ciImage.extent.size)
    }
}
