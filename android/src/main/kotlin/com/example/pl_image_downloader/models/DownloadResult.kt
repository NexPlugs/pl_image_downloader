package com.example.pl_image_downloader.models

/**
 *  DownloadResult
 * Data class representing the result of a download operation.
 */
data class DownloadResult(
    /** The path where the file is saved. */
    val path: String,
    /** The directory where the file is saved. */
    val dictionary: String,
    /** The name of the downloaded file. */
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