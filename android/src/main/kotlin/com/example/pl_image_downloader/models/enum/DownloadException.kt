package com.example.pl_image_downloader.models.enum

import android.app.DownloadManager

enum class DownloadException(val code: String) {
    CANNOT_RESUME("cannot_resume"),
    DEVICE_NOT_FOUND("device_not_found"),
    FILE_ALREADY_EXISTS("file_already_exists"),
    FILE_ERROR("file_error"),
    HTTP_DATA_ERROR("http_data_error"),
    INSUFFICIENT_SPACE("insufficient_space"),
    TOO_MANY_REDIRECTS("too_many_redirects"),
    UNHANDLED_HTTP_CODE("unhandled_http_code"),
    UNKNOWN("unknown");

    companion object {
        fun fromReasonDownload(reason: Int): DownloadException {
            return when(reason) {
                DownloadManager.ERROR_CANNOT_RESUME -> CANNOT_RESUME
                DownloadManager.ERROR_DEVICE_NOT_FOUND -> DEVICE_NOT_FOUND
                DownloadManager.ERROR_FILE_ALREADY_EXISTS -> FILE_ALREADY_EXISTS
                DownloadManager.ERROR_FILE_ERROR -> FILE_ERROR
                DownloadManager.ERROR_HTTP_DATA_ERROR -> HTTP_DATA_ERROR
                DownloadManager.ERROR_INSUFFICIENT_SPACE -> INSUFFICIENT_SPACE
                DownloadManager.ERROR_TOO_MANY_REDIRECTS -> TOO_MANY_REDIRECTS
                DownloadManager.ERROR_UNHANDLED_HTTP_CODE -> UNHANDLED_HTTP_CODE
                else -> UNKNOWN
            }
        }
    }
}