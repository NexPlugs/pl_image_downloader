package com.example.pl_image_downloader.models

data class DownloadResult(
    val id: Long,
    val remoteUri: String?,
    val localUri: String?,
    val mediaType: String?,
    val totalSize: Int?,
    val title: String?,
    val description: String?
)