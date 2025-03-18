package com.not_orange.music

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.media.session.MediaSessionManager
import android.os.Build
import android.os.Looper
import androidx.annotation.OptIn
import androidx.core.app.NotificationCompat
import androidx.media3.common.PlaybackParameters
import androidx.media3.common.SimpleBasePlayer
import androidx.media3.common.util.UnstableApi
import androidx.media3.session.MediaSession
import androidx.media3.session.MediaStyleNotificationHelper
import com.un4seen.bass.BASS
import com.un4seen.bass.BASSHLS
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var sink: EventChannel.EventSink? = null

    private var hlsHandle: Int = 0
    private var currentStream: Int = 0

    private var startedSource: String? = null
    private var startedMetadata: Map<*, *>? = null
    private var startedCover: String? = null

    private var initialized = false
    private var mediaSession: MediaSession? = null
    private var playing = false
    private var liveStream = false

    private var repeatMode = false
    private var position = 0.0
    private var duration = 0.0
    private var finished = false

    private var playerObj: SimpleBasePlayer? = null

    override fun onDestroy() {
        if (currentStream != 0) BASS.BASS_ChannelFree(currentStream)
        if (hlsHandle != 0) BASS.BASS_PluginFree(hlsHandle)
        if (initialized) BASS.BASS_Free()
        mediaSession?.release()
        super.onDestroy()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        BASS.BASS_SetConfig(BASS.BASS_CONFIG_ANDROID_SESSIONID, -1)
        hlsHandle = BASS.BASS_PluginLoad("basshls", 0)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.not_orange.music/main_events")
                .setStreamHandler(object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        sink = events
                    }

                    override fun onCancel(arguments: Any?) {
                        sink = null
                    }
                })

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.not_orange.music/main").setMethodCallHandler { call, result ->
            val args = call.arguments as? Map<*, *>
            try {
                when (call.method) {
                    "setSource" -> {
                        if (args == null) throw IllegalArgumentException()
                        if (currentStream != 0) BASS.BASS_ChannelFree(currentStream)

                        val url = args["url"] as String
                        val metadata = args["metadata"] as Map<*, *>
                        if (!initialized) {
                            startedSource = url
                            startedMetadata = metadata
                        } else {
                            setSource(url, metadata)
                            if (repeatMode) BASS.BASS_ChannelFlags(currentStream, BASS.BASS_SAMPLE_LOOP, BASS.BASS_SAMPLE_LOOP)
                        }
                        result.success(true)
                    }

                    "play" -> {
                        if (args == null) throw IllegalArgumentException()
                        if (!initialized) {
                            initialized = BASS.BASS_Init(-1, 44100, 0)
                            if (!initialized) throw BassException(BassExceptionType.BassNotInitialized)
                        }
                        if (currentStream != 0) BASS.BASS_ChannelFree(currentStream)

                        val url = args["url"] as String
                        val metadata = args["metadata"] as Map<*, *>
                        setSource(url, metadata)
                        if (repeatMode) BASS.BASS_ChannelFlags(currentStream, BASS.BASS_SAMPLE_LOOP, BASS.BASS_SAMPLE_LOOP)

                        startAudioSession()

                        if (BASS.BASS_ChannelStart(currentStream)) {
                            //TODO send event to session
                            finished = false
                            playing = true
                            sink?.success(hashMapOf("type" to 0, "playing" to true))
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    }

                    "resume" -> {
                        if (!initialized) {
                            initialized = BASS.BASS_Init(-1, 44100, 0)
                            if (!initialized) throw BassException(BassExceptionType.BassNotInitialized)

                            if (startedSource == null) {
                                result.success(false)
                                return@setMethodCallHandler
                            }

                            setSource(startedSource!!, startedMetadata)
                            if (startedCover != null) {
                                //TODO set cover
                            }
                            if (repeatMode) BASS.BASS_ChannelFlags(currentStream, BASS.BASS_SAMPLE_LOOP, BASS.BASS_SAMPLE_LOOP)
                        }

                        checkStream()
                        startAudioSession()

                        if (BASS.BASS_ChannelStart(currentStream)) {
                            //TODO send event to session
                            finished = false
                            playing = true
                            sink?.success(hashMapOf("type" to 0, "playing" to true))
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    }

                    "pause" -> {
                        checkStream()

                        if (BASS.BASS_ChannelPause(currentStream)) {
                            //TODO send event to session
                            playing = false
                            sink?.success(hashMapOf("type" to 0, "playing" to true))
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    }

                    "seek" -> {

                    }

                    "setRepeat" -> {

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

    private fun setSource(url: String, metadata: Map<*, *>?) {
        if (!initialized) throw BassException(BassExceptionType.BassNotInitialized)

        position = 0.0
        if (currentStream != 0) BASS.BASS_ChannelFree(currentStream)

        currentStream = BASSHLS.BASS_HLS_StreamCreateURL(url, 0, null, null)
        if (currentStream == 0) throw BassException(BassExceptionType.StreamNotInitialized)


        val len = BASS.BASS_ChannelGetLength(currentStream, BASS.BASS_POS_BYTE)
        if (len != -1L) {
            liveStream = false
            duration = BASS.BASS_ChannelBytes2Seconds(currentStream, len)
        } else {
            liveStream = true
            duration = -1.0
        }

        sink?.success(hashMapOf("type" to 2, "duration" to duration))

        if (metadata == null) return
        //TODO set session metadata
    }

    @OptIn(UnstableApi::class)
    private fun startAudioSession() {
        if (mediaSession != null) return
        playerObj = object : SimpleBasePlayer(Looper.getMainLooper()) {
            override fun getState(): State {
                return State.Builder()
                        .setPlaybackState(STATE_READY)
                        .setPlayWhenReady(playing, PLAY_WHEN_READY_CHANGE_REASON_USER_REQUEST)
                        .setIsLoading(false)
                        .setContentPositionMs((position * 1000).toLong()).build()
            }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel("general", "General", NotificationManager.IMPORTANCE_DEFAULT)
            val notificationManager: NotificationManager =
                    getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
        mediaSession = MediaSession.Builder(context, playerObj!!).build()
        NotificationCompat.Builder(context, "general")
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setStyle(MediaStyleNotificationHelper.MediaStyle(mediaSession!!))
    }

    private fun checkStream() {
        if (currentStream == 0) throw BassException(BassExceptionType.StreamNotInitialized)
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
