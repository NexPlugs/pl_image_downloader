package com.example.pl_image_downloader.services

import com.example.pl_image_downloader.models.DownloadConfiguration
import com.example.pl_image_downloader.models.DownloadTask

/**
 * DownloadGlobal
 * A singleton object to hold global download configuration.
 */
object DownloadGlobal {
    /** * The global download configuration. */
    var downloadConfig: DownloadConfiguration = DownloadConfiguration.default()

    /** * A map to hold retry download tasks with their IDs as keys. */
    var retryTask: MutableMap<Int, DownloadTask> = mutableMapOf()
    /** * Adds a retry task to the map if it doesn't already exist. */
    fun addRetryTask(id: Int, task: DownloadTask) {
        if(retryTask.containsKey(id)) return
        retryTask[id] = task
    }

    /** * Removes a retry task by its ID. */
    fun removeRetryTask(id: Int) {
        retryTask.remove(id)
    }

    /** * A map to hold running download tasks with their IDs as keys. */
    var runningTask: MutableMap<Int, DownloadTask> = mutableMapOf()
    fun addRunningTask(id: Int, task: DownloadTask) {
        if(runningTask.containsKey(id)) return
        runningTask[id] = task
    }

    /** * Removes a running task by its ID. */
    fun removeRunningTask(id: Int) {
        runningTask.remove(id)
    }

    /** * Clears all tasks from both retry and running task maps. */
    fun clearAll() {
        retryTask.clear()
        runningTask.clear()
    }

}