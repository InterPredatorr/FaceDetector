//
//  SessionHandler.swift
//  FaceDetector
//
//  Created by Sevak Tadevosyan on 24.05.24.
//

import Foundation
import AVFoundation

class CameraSessionHandler: SessionHandler {
    
    let captureSession: AVCaptureSession!
    
    init(captureSession: AVCaptureSession = AVCaptureSession()) {
        self.captureSession = captureSession
    }
    
    func resume() {
        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
    }
    
    func suspend() {
        DispatchQueue.main.async {
            self.captureSession.stopRunning()
        }
    }
    
    func addDeviceInput(_ input: AVCaptureDeviceInput) {
        captureSession.addInput(input)
    }
    
    func addDataOutput(_ output: AVCaptureOutput) {
        captureSession.addOutput(output)
    }
}
