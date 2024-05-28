//
//  ImageProcessor.swift
//  FaceDetector
//
//  Created by Sevak Tadevosyan on 25.05.24.
//

import Foundation
import Vision
import UIKit

protocol ImageProcessor {
    func extractFaceContour(from image: CIImage,
                            with rect: CGRect,
                            and landmarkPoints: [CGPoint],
                            completion: (Result<UIImage, FaceDetectionError>) -> Void)
    
    func extractFaceBoundingBox(from image: CIImage,
                                with rect: CGRect,
                                completion: (Result<UIImage, FaceDetectionError>) -> Void)
}
