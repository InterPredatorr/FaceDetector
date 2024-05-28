//
//  SessionHandler.swift
//  FaceDetector
//
//  Created by Sevak Tadevosyan on 25.05.24.
//

import Foundation
import AVFoundation

protocol SessionHandler {
    var captureSession: AVCaptureSession! { get }
    func resume()
    func suspend()
    func addDeviceInput(_ input: AVCaptureDeviceInput)
    func addDataOutput(_ output: AVCaptureOutput)
}
