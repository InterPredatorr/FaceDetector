//
//  UIViewController + Extensions.swift
//  FaceDetector
//
//  Created by Sevak Tadevosyan on 24.05.24.
//

import Foundation
import UIKit

extension UIViewController {
    func showPopupMessage(with content: Presentable,
                          actions: [UIAlertAction] = [UIAlertAction(title: "OK", style: .default)]) {
        let ac = UIAlertController(title: content.title, message: content.message, preferredStyle: .alert)
        actions.forEach(ac.addAction(_:))
        DispatchQueue.main.async { [weak self] in
            self?.present(ac, animated: true)
        }
    }
}
