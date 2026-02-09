package com.example.my_app

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.OutputStream

class MainActivity : FlutterActivity() {

    private val CHANNEL = "my_app/saf"
    private val CREATE_DOCUMENT_REQUEST_CODE = 1001

    private var pendingBytes: ByteArray? = null
    private var pendingMime: String? = null
    private var pendingFileName: String? = null
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                if (call.method == "saveFile") {
                    val fileName = call.argument<String>("fileName")
                    val mimeType = call.argument<String>("mimeType")
                    val bytes = call.argument<ByteArray>("bytes")

                    if (fileName == null || mimeType == null || bytes == null) {
                        result.success(false)
                        return@setMethodCallHandler
                    }

                    // Prevent overlapping requests
                    if (pendingResult != null) {
                        result.success(false)
                        return@setMethodCallHandler
                    }

                    pendingBytes = bytes
                    pendingMime = mimeType
                    pendingFileName = fileName
                    pendingResult = result

                    val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                        addCategory(Intent.CATEGORY_OPENABLE)
                        type = mimeType
                        putExtra(Intent.EXTRA_TITLE, fileName)
                    }

                    startActivityForResult(intent, CREATE_DOCUMENT_REQUEST_CODE)
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode != CREATE_DOCUMENT_REQUEST_CODE) return

        val result = pendingResult
        val bytes = pendingBytes
        val mime = pendingMime

        // Reset pending state
        pendingResult = null
        pendingBytes = null
        pendingMime = null
        pendingFileName = null

        // User cancelled or invalid data
        if (resultCode != Activity.RESULT_OK || data == null || bytes == null || mime == null) {
            result?.success(false)
            return
        }

        val uri: Uri? = data.data
        if (uri == null) {
            result?.success(false)
            return
        }

        try {
            val outputStream: OutputStream? = contentResolver.openOutputStream(uri)

            if (outputStream == null) {
                result?.success(false)
                return
            }

            outputStream.use {
                it.write(bytes)
                it.flush()
            }

            result?.success(true)

        } catch (e: Exception) {
            result?.success(false)
        }
    }
}
