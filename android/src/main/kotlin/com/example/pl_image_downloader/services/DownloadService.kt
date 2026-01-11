package com.example.pl_image_downloader.services

import android.content.Context
import android.util.Log
import com.example.pl_image_downloader.models.DownloadInfo
import com.example.pl_image_downloader.models.DownloadStatus
import com.example.pl_image_downloader.models.DownloadTask
import com.example.pl_image_downloader.models.isFinished
import com.example.pl_image_downloader.services.DownloadGlobal.retryTask
import com.example.pl_image_downloader.utils.MAX_CONCURRENT_DOWNLOADS
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

        waitingTask.clear()
    }

    /** * A map to hold waiting download tasks with their IDs as keys. */
    var waitingTask: MutableMap<Long, DownloadTask> = mutableMapOf()
    fun addWaitingTask(id: Long, task: DownloadTask) {
        if(waitingTask.containsKey(id)) return
        waitingTask[id] = task
    }
    fun removeWaitingTask(id: Long) {
        waitingTask.remove(id)
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

        if(task.downloadStatus.isFinished()) {
            if(waitingTask.isNotEmpty()) {
                val nextEntry = waitingTask.entries.first()
                val nextTask = nextEntry.value
                removeWaitingTask(nextEntry.key)

                addThenRunningTask(nextTask)
            }
        }
    }

    /** Adds a running download task to the map. */
    fun addThenRunningTask(task: DownloadTask) {
        val id = task.id ?: return
        if(runningTask.containsKey(id)) return
        addRunningTask(id, task)

        val downloader = Downloader(context, initTask = task)
            .setDownloadCallBack { updatedTask ->
                handleDownloadCallBack(updatedTask)
            }

        downloader.executeDownload()

    }


    /** Starts a download based on the provided DownloadInfo. */
    fun startDownload(downloadInfo: DownloadInfo, result: MethodChannel.Result) {
        try {
            val downloadTask = DownloadTask.fromDownloadInfo(downloadInfo)
            val id = downloadTask.id ?: throw Exception("Download task ID is null")
            if(runningTask.containsKey(id)) {
                throw Exception("Download task with ID: $id is already running")
            }

            if(runningTask.size >= MAX_CONCURRENT_DOWNLOADS) {
                addWaitingTask(id, downloadTask)
                result.success(true)
                return
            }

            addThenRunningTask(downloadTask)

            result.success(true)
        } catch (e: Exception) {
            val message = "Failed to start download for URL: ${downloadInfo.url}. Error: ${e.message}"
            Log.e(TAG, message)
            result.error(TAG, message, null)
        }
    }
}