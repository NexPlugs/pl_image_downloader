package com.example.pl_image_downloader.models


/**
 * CallBack
 * An enumeration representing different types of callbacks during a download process.
 */
enum class CallBack(val method: String) {
    PROGRESS("progress"),
    RESULT("result"),
}


/**
 * DownloadCallBack
 * A sealed class representing different types of download callbacks.
 * It contains subclasses for specific callback types, such as progress updates.
 * @property callBack The type of callback.
 * @property value The value associated with the callback.
 */
sealed class DownloadCallBack {
    abstract val callBack: CallBack?
    abstract val value: Any?

    /**
     * Progress
     * A data class representing a progress update during a download.
     *
     * @property id The identifier for the download.
     */
    data class Progress(
        override val callBack: CallBack = CallBack.PROGRESS,
        override val value: Int,
        val id: Long,
    ) : DownloadCallBack() {
        fun toMap(): Map<String, Any?> {
            return mapOf(
                "method" to callBack.method,
                "value" to value,
                "id" to id,
            )
        }
    }


    /**
     * Result
     * A data class representing the result of a completed download.
     * @property id The identifier for the download.
     */
    data class Result(
        override val callBack: CallBack = CallBack.RESULT,
        override val value: DownloadResult,
        val id: Long,
    ) : DownloadCallBack() {
        fun toMap(): Map<String, Any?> {
            return mapOf(
                "method" to callBack.method,
                "value" to value.toMap(),
                "id" to id,
            )
        }
    }

}