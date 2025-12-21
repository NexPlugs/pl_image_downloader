package com.example.pl_image_downloader.models

/**
 * DownloadInfo
 * A data class representing information about a download.
 */
data class DownloadInfo(
    val url: String,
    val fileName: String,
    val fileSize: Long,
)