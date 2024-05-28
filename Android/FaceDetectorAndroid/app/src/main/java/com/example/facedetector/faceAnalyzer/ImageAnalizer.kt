package com.example.facedetector.faceAnalyzer

import android.media.Image
import androidx.annotation.OptIn
import androidx.camera.core.ExperimentalGetImage
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import com.google.android.gms.tasks.Task
import com.google.mlkit.vision.common.InputImage

abstract class ImageAnalyzer<T> : ImageAnalysis.Analyzer {

    @OptIn(ExperimentalGetImage::class)
    override fun analyze(imageProxy: ImageProxy) {
        val mediaImage = imageProxy.image
        if (mediaImage != null) {
            detectInImage(
                InputImage.fromMediaImage(mediaImage, imageProxy.imageInfo.rotationDegrees))
                .addOnSuccessListener { results -> onSuccess(results, mediaImage) }
                .addOnFailureListener { onFailure(it) }
        } else {
            imageProxy.close()
        }
    }

    protected abstract fun detectInImage(image: InputImage): Task<T>

    abstract fun resume()
    abstract fun stop()

    protected abstract fun onSuccess(
        results: T,
        image: Image
    )

    protected abstract fun onFailure(
        e: Exception
    )

}