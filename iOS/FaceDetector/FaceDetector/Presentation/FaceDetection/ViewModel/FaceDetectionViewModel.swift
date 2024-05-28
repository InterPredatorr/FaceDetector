import Foundation
import AVFoundation
import Vision
import UIKit
import Photos

enum FaceCropType {
    case contour
    case box
}

class FaceDetectionViewModel: NSObject {
    private var sessionHandler: SessionHandler
    private var cameraManager: CameraManager
    private var faceDetector: FaceDetector
    private var imageProcessor: ImageProcessor
    private var libraryManager: PhotoLibraryManager
    private var detectionTimer: DetectionTimer
    
    weak var delegate: FaceDetectionViewModelDelegate?
    
    var isDetecting: Bool = false {
        didSet {
            delegate?.viewModel(didChangeDetectionState: isDetecting)
        }
    }
    
    var captureSession: AVCaptureSession {
        sessionHandler.captureSession
    }
    
    init(sessionHandler: SessionHandler,
         cameraManager: CameraManager,
         faceDetector: FaceDetector,
         imageProcessor: ImageProcessor,
         libraryManager: PhotoLibraryManager,
         detectionTimer: DetectionTimer) {
        self.sessionHandler = sessionHandler
        self.cameraManager = cameraManager
        self.faceDetector = faceDetector
        self.imageProcessor = imageProcessor
        self.libraryManager = libraryManager
        self.detectionTimer = detectionTimer
    }
    
    func startSession() {
        self.sessionHandler.resume()
        self.libraryManager.delegate = self
    }
    
    func resumeSession() {
        self.delegate?.viewModel(didChangeDetectionState: true)
        self.startDetectionTimer()
        self.isDetecting = true
    }
    
    func suspendSession() {
        detectionTimer.stop()
        delegate?.viewModel(didChangeDetectionState: false)
        isDetecting = false
    }
    
    private func startDetectionTimer() {
        detectionTimer.start { [weak self] in
            guard let self else { return }
            self.delegate?.viewModel(didFailWithError: FaceDetectionError.noFaceFound)
        }
    }
    
    func addCameraDataOutput() {
        cameraManager.setupCameraDataOutput(delegate: self, completion: { result in
            switch result {
            case .success(let output):
                sessionHandler.addDataOutput(output)
            case .failure(let error):
                delegate?.viewModel(didFailToSetupCameraWithError: error)
            }
        })
    }
    
    func addCameraInput() {
        do {
            let inputDevice = try cameraManager.getCaptureDeviceInput()
            self.sessionHandler.addDeviceInput(inputDevice)
        } catch let error as CameraError {
            delegate?.viewModel(didFailToSetupCameraWithError: error)
        } catch {
            delegate?.viewModel(didFailToSetupCameraWithError: CameraError.unknown)
        }
    }
    
    func detectFace(sampleBuffer: CMSampleBuffer) {
        guard let attachments = faceDetector.getAttachments(from: sampleBuffer) as? [CIImageOption : Any],
              let cvImageBuffer = sampleBuffer.imageBuffer else {
            return
        }
        
        let ciImage = CIImage(cvImageBuffer: cvImageBuffer, options: attachments)
        
        self.faceDetector.detectFace(in: sampleBuffer) { [weak self] result in
            self?.handleDetectionResults(result: result, image: ciImage)
        }
    }
    
    private func detectionSucceed(result: Result<[VNFaceObservation], FaceDetectionError>) -> Bool {
        switch result {
        case let .success(faceObservations):
            return checkValidity(faceObservations.count)
        case let .failure(error):
            self.delegate?.viewModel(didFailWithError: error)
            return false
        }
    }
    
    private func checkValidity(_ faceCount: Int) -> Bool {
        if faceCount == 0 { return false }
        if faceCount == 1 { return true }
        else {
            self.suspendSession()
            self.delegate?.viewModel(didFailWithError: FaceDetectionError.faceCount)
            return false
        }
    }
    
    private func pointsFrom(_ observation: VNFaceObservation, in image: CIImage) -> [CGPoint] {
        guard let landmarks = observation.landmarks,
              let allPoints = landmarks.allPoints,
              let medianLine = landmarks.medianLine else { return [] }
        return allPoints.toCGPoint(for: image) + medianLine.toCGPoint(for: image)
    }
    
    private func handleDetectionResults(result: Result<[VNFaceObservation], FaceDetectionError>, image: CIImage) {
        switch result {
        case .success(let faceObservations):
            if self.detectionSucceed(result: result) {
                self.suspendSession()
                sendDetectionSuccessDelegation(image: image,
                                               observations: faceObservations)
            }
        case .failure(let error):
            self.delegate?.viewModel(didFailWithError: error)
        }
    }
    
    private func sendDetectionSuccessDelegation(image: CIImage, observations: [VNFaceObservation]) {
        let options: [() -> Void] = [
            { [weak self] in
                self?.extractFace(from: image,
                                  observations: observations,
                                  cropType: .contour)
            },
            { [weak self] in
                self?.extractFace(from: image,
                                  observations: observations,
                                  cropType: .box)
            }
        ]
        self.delegate?.viewModel(didRequireShowingOptionsFor: PopupContent.cropOption,
                                 actions: options)
    }
    
    private func extractFace(from image: CIImage,
                             observations: [VNFaceObservation]?,
                             cropType: FaceCropType) {
        guard let observation = observations?.first else { return }
        switch cropType {
        case .contour:
            imageProcessor.extractFaceContour(from: image,
                                              with: observation.boundingBox,
                                              and: pointsFrom(observation, in: image),
                                              completion: handleImageExporting(result:))
        case .box:
            imageProcessor.extractFaceBoundingBox(from: image,
                                                  with: observation.boundingBox,
                                                  completion: handleImageExporting(result:))
        }
    }
    
    private func handleImageExporting(result: Result<UIImage, FaceDetectionError>) {
        switch result {
        case let .success(image):
            libraryManager.saveImageToPhotos(image)
        case let .failure(error):
            self.delegate?.viewModel(didFailWithError: error)
        }
    }
}

// MARK: - PhotoLibraryManagerDelegate
extension FaceDetectionViewModel: PhotoLibraryManagerDelegate {
    func didSaveImageSuccessfully() {
        self.delegate?.viewModelDidDetectFaces()
    }
    
    func didFailToSaveImage(with error: any Error) {
        self.delegate?.viewModel(didFailWithError: ImageSavingError.failedToSave)
    }
    
    func authorizationDenied() {
        self.delegate?.viewModel(didFailWithError: ImageSavingError.notAuthorized)
    }
}

//MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension FaceDetectionViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        if isDetecting {
            detectFace(sampleBuffer: sampleBuffer)
        }
    }
}
