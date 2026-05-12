import 'package:pl_image_downloader/src/services/channel/stream_download_channel.dart';

import '../../pl_image_downloader.dart';
import '../models/download_event_bridge.dart';
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

  ///Download Pause
  ///This method is used to pause the download task.
  ///@param id The id of the download task.
  ///@return A future that completes when the download task is paused.
  Future<bool> downloadPause(int id) async {
    try {
      await DownloadChannel.downloadPause(id);
      return true;
    } catch (e) {
      Logger.e(tag, "[DownloadPause] Error: $e");
      return false;
    }
  }

  ///Download Resume
  ///This method is used to resume the download task.
  ///@param id The id of the download task.
  ///@return A future that completes when the download task is resumed.
  Future<bool> downloadResume(int id) async {
    try {
      await DownloadChannel.downloadResume(id);
      return true;
    } catch (e) {
      Logger.e(tag, "[DownloadResume] Error: $e");
      return false;
    }
  }

  ///Download Cancel
  ///This method is used to cancel the download task.
  ///@param id The id of the download task.
  ///@return A future that completes when the download task is canceled.
  Future<bool> downloadCancel(int id) async {
    try {
      await DownloadChannel.downloadCancel(id);
      return true;
    } catch (e) {
      Logger.e(tag, "[DownloadCancel] Error: $e");
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
