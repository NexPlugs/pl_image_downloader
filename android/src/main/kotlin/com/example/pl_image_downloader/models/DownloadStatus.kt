package com.example.pl_image_downloader.models

import android.app.DownloadManager

enum class DownloadStatus {
    IDLE,
    PENDING,
    IN_PROGRESS,
    COMPLETED,
    FAILED,
    CANCELED,
    PAUSED
}


fun Int.fromStatusCode(): DownloadStatus {
    return when (this) {
        DownloadManager.STATUS_PENDING -> DownloadStatus.PENDING
        DownloadManager.STATUS_RUNNING -> DownloadStatus.IN_PROGRESS
        DownloadManager.STATUS_SUCCESSFUL -> DownloadStatus.COMPLETED
        DownloadManager.STATUS_FAILED -> DownloadStatus.FAILED
        DownloadManager.STATUS_PAUSED -> DownloadStatus.PAUSED
        else -> DownloadStatus.IDLE
    }
}


fun DownloadStatus.isInProgress(): Boolean {
    return this == DownloadStatus.PENDING || this == DownloadStatus.IN_PROGRESS
}

fun DownloadStatus.isFinished(): Boolean {
    return this == DownloadStatus.COMPLETED || this == DownloadStatus.FAILED || this == DownloadStatus.CANCELED
}