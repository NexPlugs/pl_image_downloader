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

    /** * Marks the download task as successful and updates its properties accordingly. */
    fun success(): DownloadTask {
        return this.copy(
            downloadStatus = DownloadStatus.COMPLETED,
            progress = 100,
            result = DownloadResult(
                path = destinationPath,
                dictionary = destinationPath.substringBeforeLast("/"),
                fileName = fileName,
                isSuccess = true
            )
        )
    }

    /** * Marks the download task as failed and updates its properties accordingly. */
    fun failed(errorMessage: String? = null, exception: DownloadException): DownloadTask {
        return this.copy(
            downloadStatus = DownloadStatus.FAILED,
            exception = exception,
            result = DownloadResult(
                path = destinationPath,
                dictionary = destinationPath.substringBeforeLast("/"),
                fileName = fileName,
                isSuccess = false,
                errorMessage = errorMessage ?: exception.name
            )
        )
    }
}