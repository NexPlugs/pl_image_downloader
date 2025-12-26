package com.example.pl_image_downloader.models

/**
 *  DownloadResult
 * Data class representing the result of a download operation.
 */
data class DownloadResult(
    val path: String,
    val dictionary: String,
    val fileName: String
) {
    /** * Converts the DownloadResult instance to a Map representation. */
    fun toMap(): Map<String, Any> {
        return mapOf(
            "path" to path,
            "fileName" to fileName,
            "directoryResult" to dictionary,
        )
    }
}