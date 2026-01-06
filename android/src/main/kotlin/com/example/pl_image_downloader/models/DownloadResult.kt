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
    val fileName: String,
    /** Indicates whether the download was successful. */
    val isSuccess: Boolean,
    /** An optional error message if the download failed. */
    val errorMessage: String? = null
) {
    /** * Converts the DownloadResult instance to a Map representation. */
    fun toMap(): Map<String, Any> {
        val result = mapOf(
            "path" to path,
            "fileName" to fileName,
            "directoryResult" to dictionary,
            "isSuccess" to isSuccess,
        )
        errorMessage ?: return result
        return result + mapOf("errorMessage" to errorMessage)
    }
}