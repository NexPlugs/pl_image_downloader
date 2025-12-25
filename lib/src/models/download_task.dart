import 'download_info.dart';
import '../enum/download_status.dart';

/// Download Task
/// This class is used to store the download task.
class DownloadTask {
  /// The id of the download task.
  final int id;

  /// The url of the download task.
  final String url;

  /// The file name of the download task.
  final String? fileName;

  /// The result of the download directory.
  final String? downloadDirectoryResult;

  /// The progress of the download task.
  final int? progress;

  /// The status of the download task.
  final DownloadStatus status;

  DownloadTask({
    required this.id,
    required this.url,
    this.fileName,
    this.progress,
    this.downloadDirectoryResult,
    this.status = DownloadStatus.idle,
  });

  /// Create a download task from a download info.
  factory DownloadTask.fromInfo({required DownloadInfo info}) {
    return DownloadTask(id: info.id, url: info.url, fileName: info.fileName);
  }

  DownloadTask copyWith({int? progress, DownloadStatus? status}) {
    return DownloadTask(id: id, url: url, fileName: fileName);
  }
}
