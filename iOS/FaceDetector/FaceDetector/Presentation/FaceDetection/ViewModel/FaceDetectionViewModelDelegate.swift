//
//  FaceDetectionViewModelDelegate.swift
//  FaceDetector
//
//  Created by Sevak Tadevosyan on 28.05.24.
//

import Foundation

protocol FaceDetectionViewModelDelegate: AnyObject {
    func viewModelDidDetectFaces()
    func viewModel(didFailWithError message: Presentable)
    func viewModel(didFailToSetupCameraWithError message: Presentable)
    func viewModel(didChangeDetectionState isDetecting: Bool)
    func viewModel(didRequireShowingOptionsFor content: Presentable, actions: [() -> Void])
}
