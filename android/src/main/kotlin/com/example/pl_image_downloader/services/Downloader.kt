package com.example.pl_image_downloader.services

import android.annotation.SuppressLint
import android.app.DownloadManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.IntentFilter
import android.util.Log
import androidx.core.content.ContextCompat
import com.example.pl_image_downloader.models.DownloadInfo
import com.example.pl_image_downloader.models.DownloadStatus
import com.example.pl_image_downloader.models.DownloadTask
import com.example.pl_image_downloader.models.fromStatusCode
import com.example.pl_image_downloader.models.isInProgress
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import androidx.core.net.toUri
import com.example.pl_image_downloader.models.DownloadDirectory
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.math.BigDecimal
import java.math.RoundingMode

/**
 * Constant value
 */
const val DOWNLOAD_DELAY = 1000L

/**
 * Downloader
 * A class responsible for handle downloading images. (one task per instance)
 */
class Downloader(
    val context: Context,
    val downloadInfo: DownloadInfo
) {
    companion object {
        const val TAG = "Downloader"
    }


    private val downloadManager: DownloadManager =  context.getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager

    /** * The download task associated with this downloader. */
    var downloadTask: DownloadTask = DownloadTask.fromDownloadInfo(downloadInfo)
        set(value) {
            Log.d(TAG, "Download task updated: $value")
            field = value
        }

    /** * The current status of the download task. */
    val status: DownloadStatus get() { return downloadTask.downloadStatus }

    val dictionary: DownloadDirectory get() { return downloadInfo.dictionary }

    /** * Coroutine scope for managing download operations. */
    private val downloadScope = CoroutineScope(Dispatchers.IO + SupervisorJob())


    /** * Region:  Broadcast Receiver to listen for download completion. */
    private val localReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: android.content.Intent?) {
            val id = intent?.getLongExtra(DownloadManager.EXTRA_DOWNLOAD_ID, -1L)
            val taskId = downloadTask.id
            if((id == null || id == -1L) || taskId == null) return
            if(id == taskId) {
                resolveDownloadStatus()
            }
        }
    }

    private fun registerReceiver() {
        ContextCompat.registerReceiver(
            context.applicationContext,
            localReceiver,
            IntentFilter(DownloadManager.ACTION_DOWNLOAD_COMPLETE),
            ContextCompat.RECEIVER_EXPORTED
        )
    }


    private fun unregisterReceiver() {
        try {
            context.applicationContext.unregisterReceiver(localReceiver)
        } catch (e: IllegalArgumentException) {
            Log.w(TAG, "Receiver not registered: ${e.message}")
        }
    }

    /** * End Region: Broadcast Receiver */

    fun getRequest(): DownloadManager.Request {
        val request = DownloadManager.Request(downloadTask.url.toUri())
            .setTitle(downloadTask.fileName)
            .setDestinationInExternalPublicDir(dictionary.toEnv(), downloadTask.fileName)
            .setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
            .setAllowedOverMetered(true)
            .setAllowedOverRoaming(true)

        return request
    }

    /** * Starts the download process. */
    fun executeDownload() {
        if(status.isInProgress()) return

        if(downloadTask.url.isEmpty()) {
            Log.e(TAG, "Download URL is empty.")
            downloadTask = downloadTask.copy(downloadStatus = DownloadStatus.FAILED)
            return
        }
        registerReceiver()

        downloadScope.launch {
            val request = getRequest()
            val downloadId = downloadManager.enqueue(request)

            downloadTask = downloadTask.copy(
                id = downloadId,
                downloadStatus = DownloadStatus.IN_PROGRESS
            )

            while (status.isInProgress()) {

                val progress = getProcess(downloadId)
                Log.d(TAG, "Download progress for task ${downloadTask.id}: $progress%")

                downloadTask = downloadTask.copy(progress = progress)
                delay(DOWNLOAD_DELAY)
            }
        }
    }


    @SuppressLint("Range")
    private fun getProcess(taskId: Long): Int {
        runCatching {
            val query = DownloadManager.Query().setFilterById(taskId)
            downloadManager.query(query)?.use { cursor ->
                if(cursor.moveToFirst()) {
                    val downloadBytes =
                        cursor.getInt(cursor.getColumnIndex(DownloadManager.COLUMN_BYTES_DOWNLOADED_SO_FAR))

                    val totalBytes =
                        cursor.getInt(cursor.getColumnIndex(DownloadManager.COLUMN_TOTAL_SIZE_BYTES))

                    val status =  cursor.getInt(cursor.getColumnIndex(DownloadManager.COLUMN_STATUS))
                    if(status == DownloadManager.STATUS_FAILED
                        || status == DownloadManager.STATUS_SUCCESSFUL) {


                        downloadTask = downloadTask.copy(
                            downloadStatus = status.fromStatusCode()
                        )

                        cursor.close()
                        return 100
                    }

                    val progress = BigDecimal(downloadBytes).divide(
                        BigDecimal(totalBytes),
                        2,
                        RoundingMode.DOWN
                    ).multiply(
                        BigDecimal(100)
                    ).setScale(0, RoundingMode.DOWN).toInt()

                    return progress
                }

                cursor.close()
            }
            return 0
        }.getOrElse {
            Log.e(TAG, "Error getting download progress for task $taskId: ${it.message}")
            return 0
        }
    }

    /** * Resolves the current download status by querying the DownloadManager. */
    private fun resolveDownloadStatus() {
        val taskId = downloadTask.id ?: return
        val query = DownloadManager.Query().setFilterById(taskId)

        downloadManager.query(query)?.use { cursor ->
            if(cursor.moveToFirst()) {
                val status = cursor.getInt(cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_STATUS))
                val reason = cursor.getInt(cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_REASON))

                downloadTask = downloadTask.copy(
                    downloadStatus = status.fromStatusCode()
                )

                when(status) {
                    DownloadManager.STATUS_SUCCESSFUL -> {
                        Log.d(TAG, "Download completed successfully for task $taskId")
                        unregisterReceiver()
                    }
                    DownloadManager.STATUS_FAILED -> {
                        Log.e(TAG, "Download failed for task $taskId. Reason code: $reason")
                        unregisterReceiver()
                    }
                }

                cursor.close()
            }
        }
    }
}