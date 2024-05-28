package com.example.facedetector.imageProcessor

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.PointF
import android.graphics.PorterDuff
import android.graphics.Rect
import androidx.core.graphics.toXfermode
import com.example.facedetector.extensions.rotate

enum class CropType {
    CONTOUR,
    BOX
}

object ImageProcessor  {

    fun cropImageByType(type: CropType,
                        bitmap: Bitmap,
                        points: List<PointF> = emptyList(),
                        rect: Rect = Rect()
    ): Bitmap {
        val image = bitmap.rotate(-90F)
        return when (type) {
            CropType.CONTOUR -> {
                cropFaceContour(image, points)
            }
            CropType.BOX -> {
                boundingBox(image, rect)
            }
        }
    }

    private fun cropFaceContour(image: Bitmap, points: List<PointF>): Bitmap {
        val path = getPathFrom(points)
        val output = Bitmap.createBitmap(image.width, image.height, image.config)
        val canvas = Canvas(output)
        val paint = Paint()
        paint.color = Color.BLACK
        canvas.drawPath(path, paint)

        paint.xfermode = PorterDuff.Mode.SRC_ATOP.toXfermode()

        canvas.drawBitmap(image, 0f, 0f, paint)
        return output
    }

    fun boundingBox(image: Bitmap, toFace: Rect): Bitmap {
        val width = toFace.width().toFloat()
        val height = toFace.height().toFloat()
        val x = toFace.left.toFloat()
        val y = toFace.top.toFloat()
        return Bitmap.createBitmap(
            image,
            x.toInt(),
            y.toInt(),
            width.toInt(),
            height.toInt()
        )
    }

    private fun getPathFrom(points: List<PointF>): Path {
        return Path().apply {
            if (points.isNotEmpty()) {
                moveTo(points.first().x, points.first().y)
                points.drop(1).forEach { lineTo(it.x, it.y) }
                close()
            }
        }
    }

}