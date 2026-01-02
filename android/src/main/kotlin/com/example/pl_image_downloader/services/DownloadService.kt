package com.example.pl_image_downloader.services

import com.example.pl_image_downloader.models.DownloadTask
import com.example.pl_image_downloader.services.DownloadGlobal.retryTask

object DownloadService  {

    const val TAG = "PLImageDownloader_Service"

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




}