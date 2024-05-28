package com.example.facedetector.faceAnalyzer

import android.media.Image
import android.util.Log
import androidx.camera.core.ImageProxy
import com.google.android.gms.tasks.Task
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.face.Face
import com.google.mlkit.vision.face.FaceDetection
import com.google.mlkit.vision.face.FaceDetectorOptions
import java.io.IOException

class FaceAnalyzer(
    private val onSuccessCallback: ((Image, Face) -> Unit)
): ImageAnalyzer<List<Face>>() {

    private val options = FaceDetectorOptions.Builder()
        .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_FAST)
        .setContourMode(FaceDetectorOptions.CONTOUR_MODE_ALL)
        .build()

    private val detector = FaceDetection.getClient(options)
    private var isActive = true

    override fun analyze(imageProxy: ImageProxy) {
        if (!isActive) {
            imageProxy.close()
            return
        }
        super.analyze(imageProxy)
    }

    override fun detectInImage(image: InputImage): Task<List<Face>> {
        return detector.process(image)
    }

    override fun resume() {
        isActive = true
    }

    override fun stop() {
        isActive = false
        try {
            detector.close()
        } catch (e: IOException) {
            Log.e(null, "Face Detector: $e")
        }
    }

    override fun onSuccess(
        results: List<Face>,
        image: Image
    ) {
        if (results.isNotEmpty()) {
            if (results.count() > 1) {
                onFailure(Exception("Face count can't be more than one."))
            } else {
                onSuccessCallback(image, results.first())
            }
        }
    }

    override fun onFailure(e: Exception) {
        Log.e(null, "Face Detector failed. $e")
    }
}