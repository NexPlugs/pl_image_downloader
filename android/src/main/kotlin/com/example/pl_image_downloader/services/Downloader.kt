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
import com.example.pl_image_downloader.models.DownloadConfiguration
import com.example.pl_image_downloader.models.DownloadResult
import com.example.pl_image_downloader.models.enum.DownloadDirectory
import com.example.pl_image_downloader.models.enum.DownloadException
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
    downloadInfo: DownloadInfo
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
            downloadCallBack?.invoke(field)
        }

    /** * The current status of the download task. */
    val status: DownloadStatus get() { return downloadTask.downloadStatus }

    /** * Callback function to notify about download task updates. */
    private var downloadCallBack: ((DownloadTask) -> Unit)? = null
    fun setDownloadCallBack(callBack: (DownloadTask) -> Unit): Downloader {
        this.downloadCallBack = callBack
        return this
    }

    /** * The global download configuration. */
    val downloadConfig: DownloadConfiguration get() { return DownloadGlobal.downloadConfig }
    val dictionary: DownloadDirectory get() { return downloadConfig.downloadDirectory }

    /** * Coroutine scope for managing download operations. */
    private val downloadScope = CoroutineScope(Dispatchers.IO + SupervisorJob())


    /** * Region:  Broadcast Receiver to listen for download completion. */
    private val localReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: android.content.Intent?) {
            val id = intent?.getLongExtra(DownloadManager.EXTRA_DOWNLOAD_ID, -1L)
            val taskId = downloadTask.enqueueId

            if(( id == null || id == -1L) || taskId == null ) return
            if( id == taskId ) resolveDownloadStatus()
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
            .setMimeType(downloadConfig.mimeType.typeName)
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
            val enqueueId = downloadManager.enqueue(getRequest())

            downloadTask = downloadTask.copy(
                enqueueId = enqueueId,
                downloadStatus = DownloadStatus.IN_PROGRESS
            )

            downloadTask.id ?: return@launch

            while (status.isInProgress()) {

                val progress = getProcess(enqueueId)
                Log.d(TAG, "Download progress for task ${downloadTask.id}: $progress%")

                downloadTask = downloadTask.copy(progress = progress)

                delay(DOWNLOAD_DELAY)
            }
        }
    }

    /** * Retrieves the current download progress for the given task ID. */
    @SuppressLint("Range")
    private fun getProcess(enqueueID: Long): Int {
        runCatching {
            val query = DownloadManager.Query().setFilterById(enqueueID)
            downloadManager.query(query)?.use { cursor ->
                if(cursor.moveToFirst()) {
                    val downloadBytes =
                        cursor.getInt(cursor.getColumnIndex(DownloadManager.COLUMN_BYTES_DOWNLOADED_SO_FAR))

                    val totalBytes =
                        cursor.getInt(cursor.getColumnIndex(DownloadManager.COLUMN_TOTAL_SIZE_BYTES))

                    val status =  cursor.getInt(cursor.getColumnIndex(DownloadManager.COLUMN_STATUS))
                    if(status == DownloadManager.STATUS_FAILED
                        || status == DownloadManager.STATUS_SUCCESSFUL) {

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
            Log.e(TAG, "Error getting download progress for task $enqueueID: ${it.message}")
            return 0
        }
    }

    /** * Resolves the current download status by querying the DownloadManager. */
    private fun resolveDownloadStatus() {
        val enqueueID = downloadTask.enqueueId ?: return
        val taskId = downloadTask.id ?: return
        val query = DownloadManager.Query().setFilterById(enqueueID)

        downloadManager.query(query)?.use { cursor ->
            if(cursor.moveToFirst()) {
                val status = cursor.getInt(cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_STATUS))
                val reason = cursor.getInt(cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_REASON))

                downloadTask = downloadTask.copy(
                    downloadStatus = status.fromStatusCode()
                )

                when(status) {
                    DownloadManager.STATUS_SUCCESSFUL -> {
                        Log.d(TAG, "Download completed successfully for task $enqueueID-$taskId")

                        downloadTask = downloadTask.copy(
                            progress = 100,
                            downloadStatus = DownloadStatus.COMPLETED,

                            result = DownloadResult(
                                fileName = downloadTask.fileName,
                                dictionary = "", //TODO: get the actual directory
                                path =  "" //TODO: get the actual path
                            )
                        )

                        unregisterReceiver()
                    }
                    DownloadManager.STATUS_FAILED -> {
                        Log.e(TAG, "Download failed for task $enqueueID-$taskId. Reason code: $reason")

                        val exception = DownloadException.fromReasonDownload(reason)
                        downloadTask = downloadTask.copy(
                            exception = exception,
                            downloadStatus = DownloadStatus.FAILED,
                        )

                        unregisterReceiver()
                    }
                }

                cursor.close()
            }
        }
    }
}