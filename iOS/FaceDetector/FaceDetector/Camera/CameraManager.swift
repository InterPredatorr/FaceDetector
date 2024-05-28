//
//  CameraManager.swift
//  FaceDetector
//
//  Created by Sevak Tadevosyan on 24.05.24.
//

import Foundation
import AVFoundation
import UIKit

class CameraManager {
    
    let videoDataOutput: AVCaptureVideoDataOutput!
    let queue = DispatchQueue(label: "camera_frame_receiveing_queue")
    
    init(videoDataOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()) {
        self.videoDataOutput = videoDataOutput
    }
    
    func setupCameraDataOutput(delegate: AVCaptureVideoDataOutputSampleBufferDelegate, completion: (Result<AVCaptureOutput, CameraError>) -> Void) {
        videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) :
                                            NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(delegate,
                                                queue: queue)
        guard let videoDataOutput else {
            completion(.failure(.videoDataOutputFailure))
            return
        }
        
        completion(.success(videoDataOutput))
        
        guard let connection = videoDataOutput.connection(with: .video) else {
            completion(.failure(.videoDataOutputFailure))
            return
        }
        connection.videoRotationAngle = 90.0
    }
    
    func getCaptureDeviceInput() throws -> AVCaptureDeviceInput {
        let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera,
                                                                    .builtInDualCamera,
                                                                    .builtInTrueDepthCamera],
                                                      mediaType: .video,
                                                      position: .front).devices.first
        guard let device else { throw CameraError.cameraInputFailure }
        do {
            return try AVCaptureDeviceInput(device: device)
        } catch {
            throw CameraError.cameraInputFailure
        }
    }
}
