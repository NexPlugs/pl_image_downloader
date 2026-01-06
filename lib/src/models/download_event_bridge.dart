import '../../pl_image_downloader.dart';
import 'download_call_back.dart';

import '../utils/dynamic_extensions.dart';

/// Download Event Bridge
/// This class is used to define the download event bridge.
abstract class DownloadEventBridge {
  static DownloadEventBridge fromValue(Map<String, dynamic> json) {
    final method = json['method'];
    final callBack = CallBack.fromMethodName(method);

    switch (callBack) {
      case CallBack.progress:
        return DownloadProgressEventBridge.fromValue(json);
      case CallBack.result:
        return DownloadResultEventBridge.fromValue(json);
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
    try {
      return DownloadProgressEventBridge(
        id: DynamicParser.parseInt(json['id']),
        progress: DynamicParser.parseInt(json['value']) ?? 0,
      );
    } catch (e) {
      throw Exception('DownloadProgressEventBridge not found: $e');
    }
  }
}

/// Download Result Event Bridge
/// This class is used to define the download result event bridge.
class DownloadResultEventBridge extends DownloadEventBridge {
  /// The id of the download task.
  final int? id;

  /// The result of the download.
  final DownloadResult result;
  DownloadResultEventBridge({this.id, required this.result});

  static DownloadResultEventBridge fromValue(Map<String, dynamic> json) {
    try {
      return DownloadResultEventBridge(
        id: DynamicParser.parseInt(json['id']),
        result: DownloadResult.fromJson(json['value']),
      );
    } catch (e) {
      throw Exception('DownloadResultEventBridge not found: $e');
    }
  }
}
