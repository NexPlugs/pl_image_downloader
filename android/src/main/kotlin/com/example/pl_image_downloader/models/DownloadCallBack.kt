package com.example.pl_image_downloader.models


/**
 * CallBack
 * An enumeration representing different types of callbacks during a download process.
 */
enum class CallBack(val method: String) {
    PROGRESS("progress")
}


/**
 * DownloadCallBack
 * A data class representing a callback event during a download process.
 *
 * @property callBack The type of callback event.
 * @property value An optional value associated with the callback event.
 */
data class DownloadCallBack(
    val callBack: CallBack,
    val value: Any?
) {
    companion object {
        /** Extension function to create a DownloadCallBack for progress updates. */
        fun progress(progress: Int): DownloadCallBack {
            return DownloadCallBack(CallBack.PROGRESS, progress)
        }
    }

    fun toMap(): Map<String, Any?> {
        return mapOf(
            "method" to callBack.method,
            "value" to value
        )
    }
}