//
//  PhotoLibraryManager.swift
//  FaceDetector
//
//  Created by Sevak Tadevosyan on 28.05.24.
//

import UIKit
import Photos



class PhotoLibraryManager {
    weak var delegate: PhotoLibraryManagerDelegate?
    
    private func requestAuth(completion: @escaping (Bool) -> Void) {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    completion(status == .authorized)
                }
            }
        case .restricted, .denied:
            completion(false)
        case .limited:
            completion(true)
        @unknown default:
            completion(false)
        }
    }
    
    func saveImageToPhotos(_ image: UIImage) {
        requestAuth { [weak self] authorized in
            guard let self = self else { return }
            if authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.delegate?.didFailToSaveImage(with: error)
                        } else if success {
                            self.delegate?.didSaveImageSuccessfully()
                        }
                    }
                }
            } else {
                self.delegate?.authorizationDenied()
            }
        }
    }
}
