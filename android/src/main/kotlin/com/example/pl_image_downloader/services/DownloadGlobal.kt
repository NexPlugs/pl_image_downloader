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


}