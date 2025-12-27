package com.example.pl_image_downloader.services

import com.example.pl_image_downloader.models.DownloadCallBack
import com.example.pl_image_downloader.utils.ChannelTag
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch


/**
 * DownloadBridge
 * A bridge to communicate download progress and status updates from native Android to Flutter.
 */
class DownloadBridge(
    flutterEngine: FlutterEngine
) {

    companion object {
        const val TAG = "DownloadBridge"
    }

    /** Coroutine scope for managing asynchronous tasks. */
    val scope: CoroutineScope =  CoroutineScope(Dispatchers.Main.immediate + SupervisorJob())

    private val channel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        ChannelTag.SERVICE_CHANNEL
    )


    /** Invokes a progress update on the Flutter side. */
    fun invokeProgress(progress: Int, id: Long) {
        val callBack = DownloadCallBack.Progress(
            value = progress,
            id = id
        )
        scope.launch {
            channel.invokeMethod(ChannelTag.EVENT_BRIDGE, callBack.toMap())
        }
    }


    /** Disposes the coroutine scope to clean up resources. */
    fun disposeScope() {
        scope.cancel()
    }

}