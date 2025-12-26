package com.example.pl_image_downloader.models

import com.example.pl_image_downloader.models.enum.DownloadDirectory
import com.example.pl_image_downloader.models.enum.DownloadMode
import com.example.pl_image_downloader.models.enum.MimeTypes
import com.example.pl_image_downloader.notification.NotificationConfig

/**
 * DownloadConfiguration
 * A data class representing the configuration for a download operation.
 */
data class DownloadConfiguration(
    val saveName: String? = null,
    val isExternalStorage: Boolean = false,
    val downloadMode: DownloadMode = DownloadMode.NORMAL,
    val mimeType: MimeTypes = MimeTypes.IMAGE_JPEG,
    val retryCount: Int = 3,
    val downloadDirectory: DownloadDirectory = DownloadDirectory.DOWNLOADS,
    val notificationConfig: NotificationConfig? = null,
) {
    companion object {

        /** * Provides a default DownloadConfiguration instance. */
        fun default(): DownloadConfiguration {
            return DownloadConfiguration()
        }

        /** * Checks if the current download mode. */
        fun isNormalMode(): Boolean = DownloadConfiguration().downloadMode == DownloadMode.NORMAL
        fun isBackgroundServiceMode(): Boolean = DownloadConfiguration().downloadMode == DownloadMode.RUNNING_BACKGROUND_SERVICE
    }
}


/** * Extension function to convert a Map to DownloadConfiguration. */
fun Map<*, *>.fromDownloadConfiguration(): DownloadConfiguration {
    return DownloadConfiguration(
        saveName = this["saveName"] as String?,
        isExternalStorage = this["isExternalStorage"] as Boolean,
        downloadMode = DownloadMode.fromValue(this["downloadMode"] as String),
        mimeType = MimeTypes.fromValue(this["mimeType"] as String),
        notificationConfig = null, // Handle NotificationConfig conversion if needed
        retryCount = this["retryCount"] as Int,
        downloadDirectory = DownloadDirectory.fromString(this["downloadDirectory"] as String)
    )
}