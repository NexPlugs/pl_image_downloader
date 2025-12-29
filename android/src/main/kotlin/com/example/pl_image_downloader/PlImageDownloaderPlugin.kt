package com.example.pl_image_downloader

import android.util.Log
import com.example.pl_image_downloader.services.DownloadHandler
import com.example.pl_image_downloader.utils.ChannelTag
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

/** PlImageDownloaderPlugin */
class PlImageDownloaderPlugin :
    FlutterPlugin,
    ActivityAware {

    // The MethodChannel that will the communication between Flutter and native Android
    //
    companion object {
        const val TAG = "PlImageDownloaderPlugin"
    }
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity

    /// Flag to track if the service has been started
    private var isServiceStarted = false

    /// ActivityPluginBinding to manage activity lifecycle events
    private var activityBinding: ActivityPluginBinding? = null

    //  Reference to the DownloadHandler service
    private var service: DownloadHandler? = null

    /// Reference to the FlutterEngine
    private var flutterEngine: FlutterEngine? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterEngine = flutterPluginBinding.flutterEngine
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        flutterEngine = null
    }

    // ----------------- ActivityAware -----------------
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.d(TAG, "Plugin attached to activity.")
        activityBinding = binding
        val activity = binding.activity

        service = DownloadHandler.getInstance() ?: DownloadHandler()

        val context = activity.applicationContext

        val engine = flutterEngine ?: return

        MethodChannel(
            engine.dartExecutor.binaryMessenger,
            ChannelTag.SERVICE_CHANNEL
        ).setMethodCallHandler { call , result ->
            Log.d(TAG, "Method call received: ${call.method} with arguments: ${call.arguments}")
            service?.doAction(
                method = call.method,
                argument = call.arguments,
                context = context,
                errorLogBack = { errorMessage ->
                    //TODO: Improve error handling mechanism
                },
                flutterEngine = engine,
                result = result
            )
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        cleanup()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        cleanup()
    }

    /** Cleans up resources when the plugin is detached from the activity. */
    private fun cleanup() {
        Log.d(TAG, "Plugin detached from activity.")
        activityBinding = null

        service?.dispose()
        service = null
    }

}
