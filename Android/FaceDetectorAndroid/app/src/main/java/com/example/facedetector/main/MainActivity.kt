package com.example.facedetector.main

import android.os.Bundle
import android.view.ViewGroup
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.camera.core.ExperimentalGetImage
import androidx.camera.view.PreviewView
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.ui.Modifier
import com.example.facedetector.imageProcessor.CropType
import com.example.facedetector.presentation.CameraPreviewScreen
import com.example.facedetector.presentation.CameraViewModel
import com.example.facedetector.ui.theme.FaceDetectorTheme
import com.example.facedetector.utilities.setupPermissions


@ExperimentalGetImage
class MainActivity : ComponentActivity() {

    private lateinit var previewView: PreviewView
    private lateinit var cameraViewModel: CameraViewModel
    var openAlertDialog = mutableStateOf(false)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setupPermissions(android.Manifest.permission.CAMERA, this::setCameraPreview, this::showCameraDeniedToast)
        setupPermissions(android.Manifest.permission.WRITE_EXTERNAL_STORAGE, {}, this::showStorageDeniedToast)
        setupCamera()
    }

    private fun setCameraPreview() {
        setContent {
            FaceDetectorTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    Box {
                        if (openAlertDialog.value) {
                            CropOptionDialog()
                        }
                        CameraPreviewScreen(viewModel = cameraViewModel, previewView)
                    }
                }
            }
        }
    }

    @Composable
    private fun CropOptionDialog() {
        AlertDialog(
            title = { Text("Choose Crop Type") },
            onDismissRequest = { },
            confirmButton = {
                Button(onClick = {
                    cameraViewModel.saveImageToGallery(CropType.CONTOUR)
                    openAlertDialog.value = false
                }) {
                    Text(text = "Contour Crop")
                }
            }, dismissButton = {
                Button(onClick = {
                    cameraViewModel.saveImageToGallery(CropType.BOX)
                    openAlertDialog.value = false
                }) {
                    Text(text = "Box Crop")
                }
            })
    }

    private fun setupCamera() {
        previewView = PreviewView(this).apply {
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        }
        cameraViewModel = CameraViewModel(
            this,
            this,
            onFaceDetected = {
                openAlertDialog.value = true
            }
        )
        setCameraPreview()
        cameraViewModel.startCamera(previewView)
    }

    private fun showCameraDeniedToast() {
        Toast.makeText(this, "Please grant camera permission", Toast.LENGTH_LONG).show()
    }

    private fun showStorageDeniedToast() {
        Toast.makeText(this, "Please grant gallery permission", Toast.LENGTH_LONG).show()
    }
}
