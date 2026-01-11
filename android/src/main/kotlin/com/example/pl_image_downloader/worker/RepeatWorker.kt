package com.example.pl_image_downloader.worker

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters

/**
 * RepeatWorker
 * A worker that performs repeated tasks in the background.
 * @param context The application context.
 * @param params The worker parameters.
 */
class RepeatWorker(
    context: Context,
    params: WorkerParameters
): CoroutineWorker(context, params) {
    companion object {
        const val TAG = "RepeatWorker"
    }

    override suspend fun doWork(): Result {
        TODO("Not yet implemented")
    }


    /**
     * Downloads a bitmap from the given URL with retry logic.
     * @param url The URL of the bitmap to download.
     * @param maxRetry The maximum number of retry attempts.
     */
    private fun downloadBitmapRetry(
        url: String,
        maxRetry: Int = 3
    ) {

    }
}