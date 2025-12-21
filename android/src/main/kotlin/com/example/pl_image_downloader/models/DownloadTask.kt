package com.example.pl_image_downloader.models


/**
 *  * Data class representing a download task with its associated properties.
 */
data class DownloadTask(
    val url: String,
    val destinationPath: String = "",
    val fileName: String,
    val overwrite: Boolean = false,
    val downloadStatus: DownloadStatus = DownloadStatus.IDLE
) {
    companion object {
        /** * Extension function to convert DownloadInfo to DownloadTask. */
        fun fromDownloadInfo(info: DownloadInfo): DownloadTask {
            return DownloadTask(url = info.url, fileName = info.fileName)
        }
    }
}