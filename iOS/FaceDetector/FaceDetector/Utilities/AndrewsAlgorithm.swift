//
//  AndrewsAlgorithm.swift
//  FaceDetector
//
//  Created by Sevak Tadevosyan on 25.05.24.
//

import Foundation

import Foundation

public func cross(_ o: CGPoint, _ a: CGPoint, _ b: CGPoint) -> CGFloat {
    let lhs = (a.x - o.x) * (b.y - o.y)
    let rhs = (a.y - o.y) * (b.x - o.x)
    return lhs - rhs
}

public func convexHull<Source>(_ points: Source) -> [CGPoint]
            where Source : Collection, Source.Element == CGPoint {
    
    guard !points.isEmpty else { return Array(points) }

    var lower = [CGPoint]()
    var upper = [CGPoint]()

    let points = points.sorted { a, b in
        a.x < b.x || a.x == b.x && a.y < b.y
    }

    for point in points {
        while lower.count >= 2 {
            let a = lower[lower.count - 2]
            let b = lower[lower.count - 1]
            if cross(a, b, point) > 0 { break }
            lower.removeLast()
        }
        lower.append(point)
    }

    for point in points.lazy.reversed() {
        while upper.count >= 2 {
            let a = upper[upper.count - 2]
            let b = upper[upper.count - 1]
            if cross(a, b, point) > 0 { break }
            upper.removeLast()
        }
        upper.append(point)
    }

    lower.removeLast()
    upper.removeLast()

    return lower + upper
}


