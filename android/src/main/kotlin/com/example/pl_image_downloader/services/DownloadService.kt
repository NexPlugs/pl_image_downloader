package com.example.pl_image_downloader.services

import android.content.Context
import android.util.Log
import com.example.pl_image_downloader.models.DownloadInfo
import com.example.pl_image_downloader.models.DownloadStatus
import com.example.pl_image_downloader.models.DownloadTask
import com.example.pl_image_downloader.services.DownloadGlobal.retryTask
import io.flutter.plugin.common.MethodChannel

class DownloadService(
    private val context: Context,
    private val downloadBridge: DownloadBridge
) {

    companion object {
        const val TAG = "DownloadService"

    }

    /** * A map to hold running download tasks with their IDs as keys. */
    var runningTask: MutableMap<Long, DownloadTask> = mutableMapOf()

    fun addRunningTask(id: Long, task: DownloadTask) {
        if(runningTask.containsKey(id)) return
        runningTask[id] = task
    }

    /** * Removes a running task by its ID. */
    fun removeRunningTask(id: Long) {
        runningTask.remove(id)
    }

    /** * Clears all tasks from both retry and running task maps. */
    fun clearAll() {
        retryTask.clear()
        runningTask.clear()
    }

    /**
     * Handles download callbacks and updates the Flutter side via DownloadBridge.
     * @param task The DownloadTask containing the current download status and progress.
     */
    private fun handleDownloadCallBack(task: DownloadTask) {
        val id = task.id?: return
        when(task.downloadStatus) {
            DownloadStatus.IN_PROGRESS -> {
                val progress = task.progress
                downloadBridge.invokeProgress(progress = progress, id = id)
            }
            DownloadStatus.COMPLETED -> {
                val result = task.result ?: return
                downloadBridge.invokeResult(id = id, result = result)

                removeRunningTask(id)
                retryTask.remove(id)
            }
            DownloadStatus.FAILED -> {
                val result = task.result ?: return
                downloadBridge.invokeResult(id = id, result = result)

                removeRunningTask(id)
                retryTask.remove(id)
            }
            else -> {
                // No action needed for other statuses
            }
        }
    }


    /** Starts a download based on the provided DownloadInfo. */
    fun startDownload(downloadInfo: DownloadInfo, result: MethodChannel.Result) {
        try {
            val downloader = Downloader(context, downloadInfo)
                .setDownloadCallBack(this::handleDownloadCallBack)
            downloader.executeDownload()
            result.success(true)
        } catch (e: Exception) {
            val message = "Failed to start download for URL: ${downloadInfo.url}. Error: ${e.message}"
            Log.e(TAG, message)
            result.error(TAG, message, null)
        }
    }

}