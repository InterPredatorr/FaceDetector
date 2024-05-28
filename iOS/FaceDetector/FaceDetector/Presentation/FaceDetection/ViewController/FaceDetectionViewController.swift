//
//  FaceDetectionController.swift
//  FaceDetector
//
//  Created by Sevak Tadevosyan on 22.05.24.
//

import UIKit
import AVFoundation
import Vision

class FaceDetectionViewController: UIViewController {
    
    private typealias PreviewLayer = AVCaptureVideoPreviewLayer
    
    // MARK: - Properties
    var viewModel: FaceDetectionViewModel!
    
    private var startDetectionButton: UIButton!
    
    private lazy var previewLayer = PreviewLayer(session: self.viewModel.captureSession)
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.delegate = self
        buildDetector()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer.frame = self.view.frame
        
    }
    
    private func buildDetector() {
        viewModel.addCameraInput()
        viewModel.addCameraDataOutput()
        self.viewModel.startSession()
    }
    
    private func setupUI() {
        setupDetectionButton()
        showCameraFeed()
    }
    
    private func showCameraFeed() {
        self.previewLayer.videoGravity = .resizeAspectFill
        self.view.layer.addSublayer(self.previewLayer)
        self.view.bringSubviewToFront(startDetectionButton)
        startDetectionButton.layer.cornerRadius = 12
        self.previewLayer.frame = self.view.frame
    }
    
    @objc private func toggleDetection() {
        viewModel.resumeSession()
    }
}

// MARK: - FaceDetectionViewModelDelegate

extension FaceDetectionViewController: FaceDetectionViewModelDelegate {
    func viewModelDidDetectFaces() {
        self.showPopupMessage(with: PopupContent.saved)
    }
    
    func viewModel(didFailWithError message: Presentable) {
        self.showPopupMessage(with: message, actions: [self.retryAction])
    }
    
    func viewModel(didFailToSetupCameraWithError message: Presentable) {
        self.showPopupMessage(with: message)
    }
    
    func viewModel(didChangeDetectionState isDetecting: Bool) {
        let title = isDetecting ? "Detecting..." : "Start Detection Session"
        DispatchQueue.main.async {
            self.startDetectionButton.setTitle(title, for: .normal)
        }
        
    }
    
    func viewModel(didRequireShowingOptionsFor content: Presentable, actions: [() -> Void]) {
        let alert = UIAlertController(title: content.title, message: content.message, preferredStyle: .actionSheet)
        actions.enumerated().forEach { index, action in
            let title = (index == 0 ? "Face Contour" : "Bounding Box")
            alert.addAction(UIAlertAction(title: title, style: .default, handler: { _ in action() }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
}



// MARK: - UI Components

extension FaceDetectionViewController {
    private var retryAction: UIAlertAction {
        UIAlertAction(title: "Retry",
                      style: .default) { [weak self] _ in
            self?.viewModel.resumeSession()
        }
    }
    
    private var cancelAction: UIAlertAction {
        UIAlertAction(title: "Cancel",
                      style: .cancel) { [weak self] _ in
            self?.viewModel.suspendSession()
        }
    }
    
    private func setupDetectionButton() {
        let button = UIButton(type: .system)
        button.setTitle("Start Detection Session", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(toggleDetection), for: .touchUpInside)
        let buttonHeight: CGFloat = 50
        let buttonWidth: CGFloat = 200
        let buttonX = (view.bounds.width - buttonWidth) / 2
        let buttonY = view.bounds.height - buttonHeight - 20
        button.frame = CGRect(x: buttonX, y: buttonY,
                              width: buttonWidth,
                              height: buttonHeight)
        self.startDetectionButton = button
        view.addSubview(startDetectionButton)
    }
}
