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
    var retryTask: MutableMap<Long, DownloadTask> = mutableMapOf()
    /** * Adds a retry task to the map if it doesn't already exist. */
    fun addRetryTask(id: Long, task: DownloadTask) {
        if(retryTask.containsKey(id)) return
        retryTask[id] = task
    }

    /** * Removes a retry task by its ID. */
    fun removeRetryTask(id: Long) {
        retryTask.remove(id)
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

}