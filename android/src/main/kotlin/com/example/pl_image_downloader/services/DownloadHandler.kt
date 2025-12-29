package com.example.pl_image_downloader.services

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.util.Log
import com.example.pl_image_downloader.models.DownloadInfo
import com.example.pl_image_downloader.models.DownloadStatus
import com.example.pl_image_downloader.models.DownloadTask
import com.example.pl_image_downloader.models.enum.DownloadException
import com.example.pl_image_downloader.models.fromDownloadConfiguration
import com.example.pl_image_downloader.utils.ChannelTag
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class DownloadHandler(val activity: Activity) {

    var bridge: DownloadBridge? = null

    companion object {
        const val TAG = "DownloadHandler"

        @SuppressLint("StaticFieldLeak")
        @Volatile
        private var INSTANCE: DownloadHandler? = null

        fun getInstance(): DownloadHandler? {
            if(INSTANCE == null) {
                Log.d(TAG, "DownloadHandler is not initialized yet.")
            }
            return INSTANCE
        }
    }

    /** * Flag to indicate if the download service has been set up.*/
    private var serviceSetUp = false

    init { INSTANCE = this }

    /**
     * Initializes the download configuration based on the provided arguments from Flutter.
     * @param argument The arguments passed from Flutter, expected to be a Map.
     * @param result The MethodChannel.Result to send results back to Flutter.
     * @param flutterEngine The FlutterEngine instance for setting up the DownloadBridge.
     */
    private fun initializeDownloadConfig(
        argument: Any,
        result: MethodChannel.Result,
        flutterEngine: FlutterEngine
    ) {
        if (argument !is Map<*, *>) return

        val config = argument.fromDownloadConfiguration()
        Log.d(TAG, "Download configuration initialized: $config")

        DownloadGlobal.downloadConfig = config
        serviceSetUp = true

        bridge = DownloadBridge(flutterEngine)

        result.success(true)
    }

    /**
     * Handles the download process based on the provided arguments from Flutter.
     * @param argument The arguments passed from Flutter, expected to be a Map.
     * @param context The Android context.
     * @param result The MethodChannel.Result to send results back to Flutter.
     * @param errorLogBack A callback function to log errors back to Flutter.
     */
    private fun handleDownload(
        argument: Map<*, *>,
        context: Context,
        result: MethodChannel.Result,
        errorLogBack: (String) -> Unit
    ) {
        try {
            val downloadInfo = DownloadInfo.fromMap(argument)
            Log.d(TAG, "Starting download with info: $downloadInfo")

            val downloader = Downloader(context, downloadInfo)
                .setDownloadCallBack { task ->
                    val id = task.id ?: return@setDownloadCallBack
                    when(task.downloadStatus) {
                        DownloadStatus.IN_PROGRESS -> {
                            val progress = task.progress
                            Log.d(TAG, "Download in progress for task ID: $id, progress: $progress%")
                            bridge?.invokeProgress(progress = progress, id = id)
                        }
                        DownloadStatus.COMPLETED -> {
                            task.result ?: return@setDownloadCallBack

                            Log.d(TAG, "Download completed for task ID: $id")
                            bridge?.invokeProgress(progress = 100, id = id)

                            result.success(task.result.toMap())
                        }
                        DownloadStatus.FAILED -> {
                            Log.e(TAG, "Download failed for task ID: $id")
                            errorLogBack.invoke(task.exception?.code ?: DownloadException.UNKNOWN.code)
                        }
                        else -> { }
                    }
                }

            downloader.executeDownload()
        } catch (e: Exception) {
            val message = "Error initiating download: ${e.message}"
            Log.e(TAG, message)
            errorLogBack.invoke(message)
        }
    }

    /**
     * Handles method calls from Flutter and routes them to the appropriate native functions.
     * @param method The method name received from Flutter.
     * @param argument The arguments passed from Flutter.
     * @param context The Android context.
     */
    internal fun doAction(
        method: String,
        argument: Any,
        context: Context,
        flutterEngine: FlutterEngine,
        result: MethodChannel.Result,
        errorLogBack: (String) -> Unit,
    ) {
        if(!serviceSetUp && method != ChannelTag.INIT_DOWNLOAD_CONFIG) {
            val message =  "Service not setup. Please initialize download configuration first."

            Log.w(TAG, message)
            errorLogBack.invoke(message)
            return
        }

        when(method) {
            ChannelTag.INIT_DOWNLOAD_CONFIG -> {
                initializeDownloadConfig(argument, result, flutterEngine)
            }
            ChannelTag.DOWNLOAD -> {
                if (argument !is Map<*, *>) {
                    val message = "Invalid argument for download method. Expected a Map."
                    Log.w(TAG, message)
                    errorLogBack.invoke(message)
                    return
                }

                handleDownload(
                    argument = argument,
                    context = context,
                    result = result,
                    errorLogBack = errorLogBack
                )
            }
            else -> { Log.w(TAG, "Unknown method call: $method") }
        }
    }

    /**
     * Disposes of the DownloadHandler instance and its resources.
     */
    fun dispose() {
        bridge?.disposeScope()
        bridge = null

        serviceSetUp = false
        INSTANCE = null
    }
}