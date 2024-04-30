package com.not_orange.music

import android.net.Uri
import com.un4seen.bass.BASS
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        BASS.BASS_Init(-1, 44100, 0)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.not_orange.music/main").setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "setSource" -> {
                    }
                    else -> result.notImplemented()
                }
            } catch (ex: BassException) {
                when (ex.type) {
                    BassExceptionType.BassNotInitialized ->
                        result.error("1", "Bass lib is not initialized", null)

                    BassExceptionType.StreamNotInitialized ->
                        result.error("2", "Bass stream is not initialized", null)

                    BassExceptionType.OperationError ->
                        result.error("3", "Operation finished with error", null)
                }
            } catch (ex: Exception) {
                result.error("-1", "Unknown error", null)
            }
        }
    }
}

class BassException(type: BassExceptionType) : Exception() {
    val type: BassExceptionType

    init {
        this.type = type
    }
}

enum class BassExceptionType {
    BassNotInitialized, StreamNotInitialized, OperationError
}
