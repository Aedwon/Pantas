package com.aedwon.pantas

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.SystemClock

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "pantas/trusted_clock")
            .setMethodCallHandler { call, result ->
                if (call.method == "elapsedRealtime") {
                    result.success(SystemClock.elapsedRealtime())
                } else {
                    result.notImplemented()
                }
            }
    }
}
