package com.example.pl_image_downloader.models

import com.example.pl_image_downloader.models.enum.DownloadException


/**
 *  * Data class representing a download task with its associated properties.
 */
data class DownloadTask(
    val id: Long? = null,
    val enqueueId: Long? = null,
    val url: String,
    val destinationPath: String = "",
    val fileName: String,
    val overwrite: Boolean = false,
    val downloadStatus: DownloadStatus = DownloadStatus.IDLE,
    val progress: Int = 0,

    /** Handle exception if any occurred during the download process. */
    val exception: DownloadException? = null,

    /** Result of the download operation. */
    val result: DownloadResult? = null
) {
    companion object {
        /** * Extension function to convert DownloadInfo to DownloadTask. */
        fun fromDownloadInfo(info: DownloadInfo): DownloadTask {
            return DownloadTask(id = info.id, url = info.url, fileName = info.fileName)
        }
    }
}