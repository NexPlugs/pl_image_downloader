package com.example.pl_image_downloader.models


/**
 * DownloadInfo
 * A data class representing information about a download.
 */
data class DownloadInfo(
    /** The URL of the file to be downloaded. */
    val url: String,
    /** The name of the file to be saved. */
    val fileName: String,
    /** The size of the file to be downloaded. */
    val fileSize: Long,
    /** The directory where the file will be saved. */
    val dictionary: DownloadDirectory
)