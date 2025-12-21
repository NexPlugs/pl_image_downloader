package com.example.pl_image_downloader.services

import android.content.Context
import android.util.Log
import com.example.pl_image_downloader.models.DownloadInfo
import com.example.pl_image_downloader.models.DownloadStatus
import com.example.pl_image_downloader.models.DownloadTask
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob

/**
 * Downloader
 * A class responsible for handle downloading images. (one task per instance)
 */
class Downloader(
    context: Context,
    val downloadInfo: DownloadInfo
) {
    companion object {
        const val TAG = "Downloader"
    }

    /** * The download task associated with this downloader. */
    var downloadTask: DownloadTask = DownloadTask.fromDownloadInfo(downloadInfo)
        set(value) {
            Log.d(TAG, "Download task updated: $value")
            field = value
        }

    /** * The current status of the download task. */
    val status: DownloadStatus
        get() { return downloadTask.downloadStatus }

    /** * Coroutine scope for managing download operations. */
    private val downloadScope = CoroutineScope(Dispatchers.IO + SupervisorJob())



}