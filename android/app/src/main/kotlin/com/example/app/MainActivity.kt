package com.example.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.media.MediaScannerConnection
import android.os.Build
import androidx.annotation.NonNull

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.chho.app/media_scanner").setMethodCallHandler {
            call, result ->
            if (call.method == "scanFile") {
                val path = call.argument<String>("path")
                if (path != null) {
                    MediaScannerConnection.scanFile(
                        this,
                        arrayOf(path),
                        null,
                        null
                    )
                    result.success(null)
                } else {
                    result.error("NO_PATH", "Path is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
