package com.example.pl_image_downloader.services

import com.example.pl_image_downloader.models.DownloadCallBack
import com.example.pl_image_downloader.utils.ChannelTag
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class DownloadBridge(
    flutterEngine: FlutterEngine
) {

    companion object {
        const val TAG = "DownloadBridge"
    }

    private val channel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        ChannelTag.SERVICE_CHANNEL
    )


    /** Invokes a progress update on the Flutter side. */
    fun invokeProgress(progress: Int) {
        val callBack = DownloadCallBack.progress(progress)
        channel.invokeMethod(ChannelTag.EVENT_BRIDGE, callBack.toMap())
    }

}