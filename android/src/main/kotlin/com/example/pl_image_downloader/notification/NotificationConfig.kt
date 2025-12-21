package com.example.pl_image_downloader.notification


/**
 * * Configuration data class for notification settings.
 * * @property channelId The ID of the notification channel.
 * * @property channelName The name of the notification channel.
 * * @property notificationId The unique ID for the notification.
 */
data class NotificationConfig(
    val channelId: String,
    val channelName: String,
    val notificationId: Int
)