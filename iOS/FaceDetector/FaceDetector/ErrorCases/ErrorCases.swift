//
//  Error.swift
//  FaceDetector
//
//  Created by Sevak Tadevosyan on 24.05.24.
//

import Foundation

protocol Presentable {
    var title: String { get }
    var message: String { get }
}

enum FaceDetectionError: Presentable, Error {
    case detectionFailure
    case imageExtractFailure
    case noFaceFound
    case faceCount
    case saveFailure(message: String)
    
    
    var message: String {
        switch self {
        case .detectionFailure:
            "Face detection failed, please try again"
        case .imageExtractFailure:
            "Failed to extract image from captured frame buffer"
        case .noFaceFound:
            "Please keep the camera in front of your face."
        case .faceCount:
            "Faces count!"
        case .saveFailure(_):
            "Save error"
            
        }
    }
    
    var title: String {
        switch self {
        case .detectionFailure:
            "Detection failed"
        case .imageExtractFailure:
            "Image extract failed"
        case .noFaceFound:
            "Try again?"
        case .faceCount:
            "Faces count can't be more than one"
        case let .saveFailure(message):
            message
        }
    }
}

enum CameraError: Presentable, Error {
    case videoDataOutputFailure
    case cameraInputFailure
    case unknown
    
    var message: String {
        switch self {
        case .videoDataOutputFailure:
            "Failed to work with camera's frames!"
        case .cameraInputFailure:
            "Failed to connect phone cameras, please try again!"
        case .unknown:
            "Something went wrong"
        }
    }
    
    var title: String {
        "Failure"
    }
}

enum ImageSavingError: Presentable, Error {
    case notAuthorized
    case failedToSave
    
    var title: String {
        switch self {
        case .notAuthorized:
            "Authorization Failed"
        case .failedToSave:
            "Failed To Save"
        }
    }
    
    var message: String {
        switch self {
        case .notAuthorized:
            "Please authorize to save in photo gallery"
        case .failedToSave:
            "Failed to save photo, please try again"
        }
    }
    
}

enum PopupContent: Presentable {
    case cropOption
    case saved

    var title: String {
        switch self {
        case .cropOption:
            "Please choose crop option"
        case .saved:
            "Saved!"
        }
    }
    
    var message: String {
        switch self {
        case .cropOption:
            "Face Contour will crop face outline, Bounding Box will crop face with rectangle"
        case .saved:
            "Your altered image has been saved to your photos."
        }
    }
}


