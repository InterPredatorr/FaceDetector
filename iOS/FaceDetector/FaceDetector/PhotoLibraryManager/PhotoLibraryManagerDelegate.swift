//
//  PhotoLibraryManagerDelegate.swift
//  FaceDetector
//
//  Created by Sevak Tadevosyan on 28.05.24.
//

import Foundation

protocol PhotoLibraryManagerDelegate: AnyObject {
    func didSaveImageSuccessfully()
    func didFailToSaveImage(with error: Error)
    func authorizationDenied()
}
