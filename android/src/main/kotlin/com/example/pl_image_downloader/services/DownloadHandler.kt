package com.example.pl_image_downloader.services

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.util.Log
import com.example.pl_image_downloader.models.fromDownloadConfiguration
import com.example.pl_image_downloader.utils.ChannelTag

class DownloadHandler(val activity: Activity) {

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

    private var serviceSetUp = false

    init { INSTANCE = this }

    /**
     * Initializes the download configuration based on the provided arguments from Flutter.
     * @param argument The arguments passed from Flutter, expected to be a Map.
     * @param context The Android context.
     */
    private fun initializeDownloadConfig(argument: Any, context: Context) {
        if (argument !is Map<*, *>) return

        val config = argument.fromDownloadConfiguration()
        Log.d(TAG, "Download configuration initialized: $config")

        DownloadGlobal.downloadConfig = config
        serviceSetUp = true

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

        errorLogBack: (String) -> Unit
    ) {
        if(!serviceSetUp && method != ChannelTag.INIT_DOWNLOAD_CONFIG) {
            val message =  "Service not setup. Please initialize download configuration first."

            Log.w(TAG, message)
            errorLogBack.invoke(message)
            return
        }

        when(method) {
            ChannelTag.INIT_DOWNLOAD_CONFIG -> {
                initializeDownloadConfig(argument, context)
            }
            ChannelTag.DOWNLOAD -> {}
            else -> {
                Log.w(TAG, "Unknown method call: $method")
            }
        }
    }
}