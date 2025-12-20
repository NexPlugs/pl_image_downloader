import 'package:flutter/cupertino.dart';

/// Download Info
/// This class is used to store the download information.
class DownloadInfo {
  /// The id of the download task.
  final int id;

  /// The url of the download task.
  final String url;

  /// The file name of the download task.
  final String? fileName;

  DownloadInfo({required this.id, required this.url, this.fileName});

  /// Create a new download info.
  factory DownloadInfo.create({required String url, String? fileName}) {
    return DownloadInfo(url: url, fileName: fileName, id: UniqueKey().hashCode);
  }
}
