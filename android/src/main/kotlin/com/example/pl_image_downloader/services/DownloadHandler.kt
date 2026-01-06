package com.example.pl_image_downloader.services

import android.annotation.SuppressLint
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

class DownloadHandler(val flutterEngine: FlutterEngine) {

    var bridge: DownloadBridge? = null

    var downloadService: DownloadService? = null;

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

    init {
        INSTANCE = this

        bridge = DownloadBridge(flutterEngine)
    }

    /**
     * Initializes the download configuration based on the provided arguments from Flutter.
     * @param argument The arguments passed from Flutter, expected to be a Map.
     * @param result The MethodChannel.Result to send results back to Flutter.
     * @param flutterEngine The FlutterEngine instance for setting up the DownloadBridge.
     */
    private fun updateDownloadConfig(
        argument: Any,
        result: MethodChannel.Result,
    ) {
        if (argument !is Map<*, *>) {
            val message = "Invalid argument for download configuration. Expected a Map."
            Log.w(TAG, message)

            result.success(false)
            return
        }

        val config = argument.fromDownloadConfiguration()
        Log.d(TAG, "Download configuration initialized: $config")

        DownloadGlobal.downloadConfig = config

        result.success(true)
    }

    /**
     * Handles the download callback based on the download task status.
     * @param task The DownloadTask containing the current status and progress.
     * @param errorLogBack A callback function to log errors back to Flutter.
     * @param result The MethodChannel.Result to send results back to Flutter.
     */
    private fun handleDownloadCallBack(
        task: DownloadTask,
        errorLogBack: (String) -> Unit,
        result: MethodChannel.Result? = null,
    ) {
        val id = task.id ?: return

        when(task.downloadStatus) {
            DownloadStatus.IN_PROGRESS -> {
                val progress = task.progress
                Log.d(TAG, "Download in progress for task ID: $id, progress: $progress%")
                bridge?.invokeProgress(progress = progress, id = id)
            }
            DownloadStatus.COMPLETED -> {
                task.result ?: return

                Log.d(TAG, "Download completed for task ID: $id")
                bridge?.invokeProgress(progress = 100, id = id)

                result?.success(task.result.toMap())
            }
            DownloadStatus.FAILED -> {
                Log.e(TAG, "Download failed for task ID: $id")
                errorLogBack.invoke(task.exception?.code ?: DownloadException.UNKNOWN.code)
            }
            else -> { }
        }
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
        errorLogBack: (String) -> Unit,
        result: MethodChannel.Result? = null,
    ) {
        try {
            val downloadInfo = DownloadInfo.fromMap(argument)
            Log.d(TAG, "Starting download with info: $downloadInfo")

            val downloader = Downloader(context, downloadInfo)
                .setDownloadCallBack { task ->

                    handleDownloadCallBack(
                        task = task,  errorLogBack = errorLogBack, result = result
                    )
                }

            downloader.executeDownload()
        } catch (e: Exception) {
            val message = "Error initiating download: ${e.message}"
            Log.e(TAG, message)
            errorLogBack.invoke(message)
        }
    }



    /**
     * Handles the download service tag method call from Flutter.
     * @param argument The arguments passed from Flutter, expected to be a Map.
     * @param context The Android context.
     * @param result The MethodChannel.Result to send results back to Flutter.
     */
    private fun handleDownloadServiceTag(
        argument: Map<*, *>,
        context: Context,
        result: MethodChannel.Result? = null
    ) {
        result ?: return
        if(bridge == null) {
            val message = "DownloadBridge is not initialized."
            Log.w(TAG, message)
            result.error("DOWNLOAD_BRIDGE_UNINITIALIZED", message, null)
            return
        }
        if(downloadService == null) {
            downloadService = DownloadService(context, bridge!!)
        }
        downloadService?.startDownload(
            downloadInfo = DownloadInfo.fromMap(argument),
            result = result
        )

    }

    /**
     * Validates the type of the provided value against the expected type T.
     * Logs a warning if the type does not match.
     * @param value The value to be checked.
     * @return An empty string if the type matches, otherwise a warning message.
     */
    private inline fun<reified T> formatValidType(value: Any): String {
        val check = value is T
        if(!check) {
            val message = "Invalid argument type. Expected ${T::class.java.simpleName}, but got ${value::class.java.simpleName}."
            Log.w(TAG, message)
        }
        return ""
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
        result: MethodChannel.Result,
        errorLogBack: (String) -> Unit,
    ) {

        when(method) {
            ChannelTag.DOWNLOAD_CONFIG -> {
                updateDownloadConfig(argument, result)
            }
            ChannelTag.DOWNLOAD -> {
                val isValid = formatValidType<Map<*, *>>(argument)
                if(isValid.isNotEmpty()) {
                    errorLogBack.invoke(isValid)
                    return
                }

                handleDownload(
                    argument = argument as Map<*, *>,
                    context = context,
                    result = result,
                    errorLogBack = errorLogBack
                )
            }
            ChannelTag.DOWNLOAD_SERVICE_TAG -> {

                val isValid = formatValidType<Map<*, *>>(argument)
                if(isValid.isNotEmpty()) {
                    errorLogBack.invoke(isValid)
                    return
                }
                handleDownloadServiceTag(
                    result = result,
                    context = context,
                    argument = argument as Map<*, *>,
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

        INSTANCE = null
    }
}