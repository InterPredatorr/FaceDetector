package com.example.facedetector.utilities

import android.graphics.PointF
import androidx.camera.video.AudioSpec.Source

fun cross(o: PointF, a: PointF, b: PointF): Float {
    val lhs = (a.x - o.x) * (b.y - o.y)
    val rhs = (a.y - o.y) * (b.x - o.x)
    return lhs - rhs
}

fun <Source> convexHull(points: Source): List<PointF> where Source: Collection<PointF> {
    if (points.isEmpty()) { return emptyList() }
    val lower = mutableListOf<PointF>()
    val upper = mutableListOf<PointF>()

    val sortedPoints = points.sortedWith(compareBy({ it.x }, { it.y }))

    sortedPoints.forEach { point ->
        while (lower.count() >= 2) {
            val a = lower[lower.count() - 2]
            val b = lower[lower.count() - 1]
            if (cross(a, b, point) > 0) { break }
            lower.removeLast()
        }
        lower.add(point)
    }

    sortedPoints.reversed().forEach { point ->
        while (upper.count() >= 2) {
            val a = upper[upper.count() - 2]
            val b = upper[upper.count() - 1]
            if (cross(a, b, point) > 0) { break }
            upper.removeLast()
        }
        upper.add(point)
    }

    lower.removeLast()
    upper.removeLast()
    return lower + upper
}