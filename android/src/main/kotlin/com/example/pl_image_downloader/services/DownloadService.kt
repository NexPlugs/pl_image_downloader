package com.example.pl_image_downloader.services

import android.app.Service
import android.content.Intent
import android.os.IBinder

class DownloadService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null
}