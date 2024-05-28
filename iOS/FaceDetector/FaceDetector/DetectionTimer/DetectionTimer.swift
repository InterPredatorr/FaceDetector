//
//  DetectionTimer.swift
//  FaceDetector
//
//  Created by Sevak Tadevosyan on 24.05.24.
//

import Foundation


class DetectionTimer {
    var timer: Timer?
    let detectionDuration: TimeInterval
    
    init(with detectionDuration: TimeInterval = 10.0) {
        self.detectionDuration = detectionDuration
    }
    
    func setupDetectionTimer(completion: @escaping () -> Void) {
        let startingDate = Date.now
        timer = Timer.scheduledTimer(withTimeInterval: 1.0,
                                     repeats: true) { [weak self] timer in
            let timeElapsed = Date.now.timeIntervalSince(startingDate)
            if timeElapsed < self?.detectionDuration ?? 0.0 {
                return
            } else {
                timer.invalidate()
                completion()
            }
        }
    }
    
    func start(completion: @escaping () -> Void) {
        setupDetectionTimer { [weak self] in
            self?.stop()
            completion()
        }
        timer?.fire()
    }
    
    func stop() {
        timer?.invalidate()
    }
}
