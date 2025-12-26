package com.example.pl_image_downloader.models

import com.example.pl_image_downloader.models.enum.DownloadDirectory


/**
 * DownloadInfo
 * A data class representing information about a download.
 */
data class DownloadInfo(
    val id: Long? = null,
    /** The URL of the file to be downloaded. */
    val url: String,
    /** The name of the file to be saved. */
    val fileName: String,
    /** The size of the file to be downloaded. */
    val fileSize: Long?,
) {
    companion object {
        fun fromMap(map: Map<*, *>): DownloadInfo {
            return DownloadInfo(
                id = (map["id"] as Number?)?.toLong(),
                url = map["url"] as String,
                fileName = map["fileName"] as String,
                fileSize = (map["fileSize"] as Number?)?.toLong()
            )
        }
    }
}