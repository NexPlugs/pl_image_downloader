package com.example.pl_image_downloader.models.enum

/**
 * DownloadMode
 * An enumeration representing different download modes.
 */
enum class DownloadMode(name: String) {
    NORMAL("normal"),
    RUNNING_BACKGROUND_SERVICE("runningBackgroundService");

    val modeName = name

    companion object {
        fun fromValue(name: String): DownloadMode {
            return entries.firstOrNull { it.modeName.equals(name, ignoreCase = true) }
                ?: throw Exception("Download mode not found: $name")
        }
    }
}