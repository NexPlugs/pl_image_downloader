import 'download_call_back.dart';

/// Download Event Bridge
/// This class is used to define the download event bridge.
abstract class DownloadEventBridge {
  static DownloadEventBridge fromValue(Map<String, dynamic> json) {
    final method = json['method'];
    final callBack = CallBack.fromMethodName(method);

    switch (callBack) {
      case CallBack.progress:
        return DownloadProgressEventBridge.fromValue(json);
      default:
        throw Exception('DownloadEventBridge not found: $callBack');
    }
  }
}

/// Download Progress Event Bridge
/// This class is used to define the download progress event bridge.
class DownloadProgressEventBridge extends DownloadEventBridge {
  /// The id of the download task.
  final int? id;

  /// The progress of the download.
  final int progress;
  DownloadProgressEventBridge({this.id, required this.progress});

  static DownloadProgressEventBridge fromValue(Map<String, dynamic> json) {
    return DownloadProgressEventBridge(
      id: int.tryParse(json['id'] as String),
      progress: json['value'] as int,
    );
  }
}
