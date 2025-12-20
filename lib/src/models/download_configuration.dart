import 'download_mode.dart';
import 'mime_type.dart';
import 'notification_config.dart';

/// Download Configuration
/// This class is used to store the download configuration.
class DownloadConfiguration {
  /// The directory to save the download file.
  final String? saveDirectory;

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

  DownloadConfiguration({
    this.saveDirectory,
    this.saveName,
    this.notificationConfig,
    this.isExternalStorage = false,
    this.downloadMode = DownloadMode.normal,
    this.mimeType = MimeType.imageJpeg,
    this.retryCount = 3,
  });

  /// Convert the download configuration to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'saveDirectory': saveDirectory,
      'saveName': saveName,
      'isExternalStorage': isExternalStorage,
      'downloadMode': downloadMode.name,
      'mimeType': mimeType.name,
    };
  }
}
