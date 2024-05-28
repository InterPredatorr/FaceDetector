package com.example.facedetector.utilities


import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts

fun ComponentActivity.setupPermissions(permission: String, onGranted: () -> Unit, onDenied: () -> Unit) {
    val launcher = registerForActivityResult(ActivityResultContracts.RequestPermission()) { isGranted ->
        if (isGranted) onGranted() else onDenied()
    }
    launcher.launch(permission)
}