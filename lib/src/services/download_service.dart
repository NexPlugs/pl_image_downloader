//
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pl_image_downloader/src/models/download_configuration.dart';
import 'package:pl_image_downloader/src/models/download_info.dart';
import 'package:pl_image_downloader/src/models/download_result.dart';
import 'package:pl_image_downloader/src/models/download_task.dart';

import '../models/download_event_bridge.dart';
import '../utils/logger.dart';
import 'channel/download_channel.dart';
import 'channel/stream_download_channel.dart';

/// Download Service
/// This class is used to handle the download service.
/// This is specially Service for download image, many concurrent download task will be handled by this service.
class DownloadService {
  static const String tag = "download_service";

  ///Constructor
  DownloadService();

  ///The map of the download task controllers.
  ///The key is the id of the download task.
  ///The value is the stream controller of the download task.
  final Map<int, StreamController<DownloadTask>> _downloadTaskControllers = {};
  final Map<int, DownloadTask> _downloadTasks = {};
  final Map<int, Completer<DownloadResult>> _downloadTaskCompleters = {};

  bool _isSetUp = false;

  ///Get the stream of the download task.
  ///@param id The id of the download task.
  ///@return The stream of the download task.
  Stream<DownloadTask?> getStream(int id) async* {
    if (_downloadTaskControllers.containsKey(id)) {
      yield* _downloadTaskControllers[id]!.stream;
    }

    yield null;
  }

  DownloadTask? getTask(int id) => _downloadTasks[id];

  ///Listen to the progress of the download task.
  ///@param id The id of the download task.
  ///@param onProgress The callback function to handle the progress of the download task.
  void listenProgress(int id, void Function(int progress) onProgress) {
    getStream(id).listen((task) {
      if (task == null) {
        Logger.e(tag, "[ListenProgress] Download task not found");
        return;
      }
      onProgress(task.progress ?? 0);
    });
  }

  ///Update the download task.
  ///@param id The id of the download task.
  void _updateTask(int id, DownloadTask task) {
    if (_downloadTasks.containsKey(id)) {
      _downloadTasks[id] = task;
    }
    _downloadTaskControllers[id]?.add(task);
  }

  ///Clear the download task.
  ///@param id The id of the download task.
  void _clearTask(int id) {
    try {
      _downloadTasks.remove(id);

      final controller = _downloadTaskControllers[id];
      if (controller != null && !controller.isClosed) {
        controller.close();
        _downloadTaskControllers.remove(id);
      }

      final completer = _downloadTaskCompleters[id];
      if (completer != null && !completer.isCompleted) {
        _downloadTaskCompleters.remove(id);
      }
    } catch (e) {
      Logger.e(tag, "[ClearTask] Error: $e");
    }
  }

  ///Init the download service
  ///This method is used to initialize the download service. Need to call this method before any other method in the download service.
  ///@param downloadConfiguration The download configuration If not provided, the download configuration will be used from default.
  ///@throws Exception if the download service fails to initialize.
  Future<void> init(DownloadConfiguration? downloadConfiguration) async {
    if (_isSetUp) {
      Logger.i(tag, "[Init] Download service already initialized");
      return;
    }

    Logger.i(tag, "[Init] Initializing download service");
    try {
      if (downloadConfiguration != null) {
        await DownloadChannel.downloadConfig(downloadConfiguration);
      }

      StreamDownloadChannel.setCallBack((eventBridge) {
        Logger.i(tag, "[Init] Event bridge: $eventBridge");

        switch (eventBridge) {
          case DownloadProgressEventBridge():
            _handleDownloadProgressEventBridge(eventBridge);
            break;
          default:
            break;
        }
      }).listenEventBridge();

      Logger.i(tag, "[Init] Event bridge set");

      _isSetUp = true;
    } catch (e) {
      Logger.e(tag, "[Init] Error: $e");
      throw Exception(e);
    }
  }

  ///Download Config
  ///This method is used to download the configuration.
  ///@return A future that completes when the configuration is downloaded.
  ///@throws Exception if the configuration fails to download.
  Future<bool> downloadConfig(
    DownloadConfiguration downloadConfiguration,
  ) async {
    try {
      return await DownloadChannel.downloadConfig(downloadConfiguration);
    } catch (e) {
      Logger.e(tag, "[DownloadConfig] Error: $e");
      return false;
    }
  }

  ///Download
  ///This method is used to download a file.
  ///@param fileName The file name.
  ///@param url The url of the file.
  ///@return A future that completes when the file is downloaded.
  ///@throws Exception if the file fails to download.
  Future<DownloadResult?> download({
    String? fileName,
    required String url,
  }) async {
    if (!_isSetUp) {
      Logger.e(tag, "[Download] Download service not initialized");
      throw Exception("Download service not initialized");
    }

    final info = DownloadInfo.create(url: url, fileName: fileName);

    // Create a download task
    final downloadTask = DownloadTask.fromInfo(info: info);
    _downloadTasks[downloadTask.id] = downloadTask;
    _downloadTaskControllers[downloadTask.id]?.add(downloadTask);

    // Create a completer for the download task
    final completer = Completer<DownloadResult>();
    _downloadTaskCompleters[downloadTask.id] = completer;
    try {
      // Download the file
      final downloadResult = await DownloadChannel.download(info);
      completer.complete(downloadResult);
    } catch (e) {
      Logger.e(tag, "[Download] Error: $e");
      throw Exception(e);
    } finally {
      _clearTask(downloadTask.id);
    }

    return await completer.future;
  }

  /// Region === Event Bridge handler ===

  void _handleDownloadProgressEventBridge(
    DownloadProgressEventBridge eventBridge,
  ) {
    final id = eventBridge.id;
    if (id == null) {
      Logger.e(
        tag,
        "[HandleDownloadProgressEventBridge] Download progress event bridge id is null",
      );
      return;
    }
    final task = getTask(id);
    if (task == null) {
      Logger.e(tag, "Download task not found id: $id");
      return;
    }
    final status = task.status;
    Logger.i(
      tag,
      "[HandleDownloadProgressEventBridge] Progress: ${eventBridge.progress}",
    );
    if (status.clearTaskAfterCompletion) {
      _clearTask(id);
    } else {
      _updateTask(id, task.copyWith(progress: eventBridge.progress));
    }
  }

  /// End Region === Event Bridge handler ===

  void cleanUp() {
    for (final id in _downloadTasks.keys) {
      _clearTask(id);
    }
    _downloadTasks.clear();
    _downloadTaskCompleters.clear();

    _isSetUp = false;
  }

  /// Dispose
  /// This method is used to dispose the download service. Need to call this method when the download service is no longer needed.
  /// @throws Exception if the download service fails to dispose.
  @mustCallSuper
  void dispose() {
    cleanUp();
    StreamDownloadChannel.instance.dispose();
  }
}
