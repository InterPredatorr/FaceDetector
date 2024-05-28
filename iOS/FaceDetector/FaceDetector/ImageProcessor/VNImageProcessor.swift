//
//  VNImageProcessor.swift
//  FaceDetector
//
//  Created by Sevak Tadevosyan on 24.05.24.
//

import Foundation
import Vision
import UIKit

class VNImageProcessor: ImageProcessor {
    
    typealias ProcessingCompletion = (Result<UIImage, FaceDetectionError>) -> Void
    
    func extractFaceContour(from image: CIImage,
                            with rect: CGRect,
                            and landmarkPoints: [CGPoint],
                            completion: ProcessingCompletion) {
        guard !landmarkPoints.isEmpty,
              let contour = image.cropFaceContour(points: landmarkPoints),
              let croppedImage = CIImage(cgImage: contour).boundingBox(toFace: rect) else {
            completion(.failure(.imageExtractFailure))
            return
        }
        completion(.success(UIImage(cgImage: croppedImage)))
    }
    
    func extractFaceBoundingBox(from image: CIImage,
                                with rect: CGRect,
                                completion: ProcessingCompletion) {
        guard let croppedImage = image.boundingBox(toFace: rect) else {
            completion(.failure(FaceDetectionError.imageExtractFailure))
            return
        }
        completion(.success(UIImage(cgImage: croppedImage)))
    }
}

