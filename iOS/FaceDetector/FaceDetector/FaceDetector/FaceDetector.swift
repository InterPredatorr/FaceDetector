//
//  FaceDetector.swift
//  FaceDetector
//
//  Created by Sevak Tadevosyan on 24.05.24.
//

import Foundation
import Vision

class FaceDetector {
    
    func faceDetectionRequest(completion: @escaping (Result<[VNFaceObservation], FaceDetectionError>) -> Void) -> VNRequest {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest { request, error in
            DispatchQueue.main.async {
                if error != nil {
                    completion(.failure(.detectionFailure))
                } else if let results = request.results as? [VNFaceObservation] {
                    completion(.success(results))
                }
            }
        }
        
        return faceDetectionRequest
    }
    
    func detectFace(in image: CMSampleBuffer, completion: @escaping(Result<[VNFaceObservation], FaceDetectionError>) -> Void) {
        
        let imageRequestHandler = VNImageRequestHandler(cmSampleBuffer: image, orientation: .downMirrored, options: [:])
        try? imageRequestHandler.perform([faceDetectionRequest(completion: completion)])
    }
    
    func getAttachments(from sampleBuffer: CMSampleBuffer) -> CFDictionary? {
        CMCopyDictionaryOfAttachments(allocator: kCFAllocatorDefault,
                                      target: sampleBuffer,
                                      attachmentMode: kCMAttachmentMode_ShouldPropagate)
    }
}
