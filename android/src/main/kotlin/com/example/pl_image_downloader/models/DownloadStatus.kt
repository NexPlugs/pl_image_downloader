package com.example.pl_image_downloader.models

enum class DownloadStatus {
    IDLE,
    PENDING,
    IN_PROGRESS,
    COMPLETED,
    FAILED,
    CANCELED,
    PAUSED
}