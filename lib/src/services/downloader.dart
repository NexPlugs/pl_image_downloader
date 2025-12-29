import 'package:pl_image_downloader/src/services/channel/stream_download_channel.dart';

import '../../pl_image_downloader.dart';
import '../models/download_event_bridge.dart';
import '../models/download_info.dart';
import '../utils/async_mutex.dart';
import '../utils/logger.dart';
import 'channel/download_channel.dart';

class Downloader {
  static const String tag = "downloader";

  final AsyncMutex _mutex = AsyncMutex();

  ///This method is used to download a image file.
  ///@param downloadInfo The download info.
  ///@return The download result.
  ///@throws Exception if the download fails.
  Future<DownloadResult?> download(DownloadInfo downloadInfo) async {
    try {
      return await _mutex.run(
        () async => await DownloadChannel.download(downloadInfo),
      );
    } catch (e) {
      Logger.e(tag, "[Download] Error: $e");
      return null;
    }
  }

  ///Download Config
  ///This method is used to download the configuration.
  ///@param downloadConfiguration The download configuration.
  ///@return The download result.
  ///@throws Exception if the download fails.
  Future<bool> updateConfig(DownloadConfiguration downloadConfiguration) async {
    try {
      return await DownloadChannel.downloadConfig(downloadConfiguration);
    } catch (e) {
      Logger.e(tag, "[DownloadConfig] Error: $e");
      return false;
    }
  }

  ///Watch Progress
  ///This method is used to watch the progress of the download task.
  ///@param listener The callback function to handle the progress of the download task.
  ///@throws Exception if the watch fails.
  void watchProgress(Function(int progress) lis) {
    StreamDownloadChannel.setCallBack((eventBridge) {
      if (eventBridge is DownloadProgressEventBridge) {
        lis(eventBridge.progress);
      }
    }).listenEventBridge();
  }

  ///Dispose
  ///This method is used to dispose the downloader.
  ///@throws Exception if the dispose fails.
  void dispose() {
    StreamDownloadChannel.instance.dispose();
  }
}
