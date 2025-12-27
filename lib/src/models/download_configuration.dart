import 'package:pl_image_downloader/src/models/download_dictionary.dart';

import '../enum/download_mode.dart';
import '../enum/mime_type.dart';
import 'notification_config.dart';

/// Download Configuration
/// This class is used to store the download configuration.
class DownloadConfiguration {
  /// The name of the download file.
  final String? saveName;

  /// Whether to save the download file to external storage.
  final bool isExternalStorage; // Optional for android

  /// The download mode.
  final DownloadMode downloadMode;

  /// The mime type of the download file.
  final MimeType mimeType;

  /// The notification config.
  final NotificationConfig? notificationConfig;

  /// The retry count.
  final int retryCount;

  /// The download directory.
  final DownloadDirectory downloadDirectory;

  DownloadConfiguration({
    this.saveName,
    this.notificationConfig,
    this.isExternalStorage = false,
    this.downloadMode = DownloadMode.normal,
    this.mimeType = MimeType.imageJpeg,
    this.retryCount = 3,
    this.downloadDirectory = DownloadDirectory.downloads,
  });

  /// Convert the download configuration to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'saveName': saveName,
      'mimeType': mimeType.name,
      'downloadMode': downloadMode.name,
      'isExternalStorage': isExternalStorage,
      'retryCount': retryCount,
      'notificationConfig': notificationConfig?.toJson(),
      'downloadDirectory': downloadDirectory.directoryName,
    };
  }
}
