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
}