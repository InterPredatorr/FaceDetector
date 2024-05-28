package com.example.facedetector.presentation

import androidx.camera.view.PreviewView
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.viewinterop.AndroidView

@Composable
fun CameraPreviewScreen(
    viewModel: CameraViewModel,
    preview: PreviewView
) {
    Box(
        contentAlignment = Alignment.BottomCenter,
        modifier = Modifier.fillMaxSize()
    ) {
        AndroidView(
            { preview },
            modifier = Modifier
                .fillMaxSize()
        )
        Button(
            onClick = {
                viewModel.resumeDetection()
            }
        ) {
            Text(text = "Start Detection Session")
        }
    }


}