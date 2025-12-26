package com.example.pl_image_downloader.models.enum

import android.os.Environment

/**
 * DownloadDirectory
 * An enumeration representing various download directories.
 */
enum class DownloadDirectory(val directoryName: String) {
    MUSIC("music"),
    PICTURES("pictures"),
    PODCASTS("podcasts"),
    MOVIES("movies"),
    DOWNLOADS("downloads");

    override fun toString(): String {
        return directoryName
    }


    companion object {
        fun fromString(name: String?): DownloadDirectory {
            if (name == null) {
                return default()
            }
            return entries.find { it.directoryName.equals(name, ignoreCase = true) } ?: default()
        }

        fun default(): DownloadDirectory {
            return DOWNLOADS
        }
    }

    fun toEnv(): String? {
        return when (this) {
            MUSIC -> Environment.DIRECTORY_MUSIC
            PICTURES -> Environment.DIRECTORY_PICTURES
            PODCASTS -> Environment.DIRECTORY_PODCASTS
            MOVIES -> Environment.DIRECTORY_MOVIES
            DOWNLOADS -> Environment.DIRECTORY_DOWNLOADS
        }
    }
}