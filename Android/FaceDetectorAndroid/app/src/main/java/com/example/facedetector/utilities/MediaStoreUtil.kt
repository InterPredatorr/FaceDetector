package com.example.facedetector.utilities

import android.content.ContentResolver
import android.content.ContentValues
import android.graphics.Bitmap
import android.os.Environment
import android.provider.MediaStore

object MediaStoreUtil {
    fun saveImage(contentResolver: ContentResolver, bitmap: Bitmap, fileName: String, completion: (Boolean) -> Unit) {
        val contentValues = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, "image/jpeg")
            put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_PICTURES)
        }
        val uri = contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
        uri?.let { ur ->
            contentResolver.openOutputStream(ur).use { outputStream ->
                if (outputStream != null) {
                    completion(true)
                    bitmap.compress(Bitmap.CompressFormat.JPEG, 100, outputStream)
                } else {
                    completion(false)
                }
            }
        }
    }
}