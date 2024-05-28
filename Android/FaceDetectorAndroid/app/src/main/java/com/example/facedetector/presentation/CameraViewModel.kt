package com.example.facedetector.presentation

import android.content.Context
import android.media.Image
import android.widget.Toast
import androidx.camera.view.PreviewView
import androidx.lifecycle.LifecycleOwner
import com.example.facedetector.camera.CameraManager
import com.example.facedetector.extensions.toBitmap
import com.example.facedetector.faceAnalyzer.FaceAnalyzer
import com.example.facedetector.faceAnalyzer.ImageAnalyzer
import com.example.facedetector.imageProcessor.CropType
import com.example.facedetector.imageProcessor.ImageProcessor
import com.example.facedetector.utilities.MediaStoreUtil
import com.example.facedetector.utilities.convexHull
import com.google.mlkit.vision.face.Face
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.UUID

class CameraViewModel(
    private val context: Context,
    private val lifecycleOwner: LifecycleOwner,
    val onFaceDetected: () -> Unit
) {

    private lateinit var cameraManager: CameraManager
    private var faceDetector: ImageAnalyzer<List<Face>> = setupFaceDetector()
    private var detectedFaceImage: Image? = null
    private  var detectedFaceInfo: Face? = null

    fun startCamera(previewView: PreviewView) {
        cameraManager = CameraManager(context, lifecycleOwner, previewView, faceDetector)
        cameraManager.startCamera()
    }

    private fun setupFaceDetector(): ImageAnalyzer<List<Face>> = FaceAnalyzer { image, face ->
        detectedFaceImage = image
        detectedFaceInfo = face
        onFaceDetected()
    }

    fun saveImageToGallery(type: CropType) {
        val image = detectedFaceImage?.toBitmap()
        if (detectedFaceInfo != null && image != null) {
            val allPoints = convexHull(detectedFaceInfo!!.allContours
                .map { it.points }
                .reduce { acc, points -> acc + points })

            val croppedImage = ImageProcessor.cropImageByType(
                type,
                image,
                allPoints,
                detectedFaceInfo!!.boundingBox
            )

            MediaStoreUtil.saveImage(
                context.contentResolver,
                croppedImage,
                UUID.randomUUID().toString()
            ) {
                Toast.makeText(
                    context,
                    if (it) "Image Saved" else "Failed to save the image",
                    Toast.LENGTH_LONG
                ).show()
            }
            suspendDetection()
        }
    }

    fun resumeDetection() {
        CoroutineScope(Dispatchers.IO).launch {
            cameraManager.resumeAnalyzer()
        }
    }

    fun suspendDetection() {
        cameraManager.suspendAnalyzer()
    }
}