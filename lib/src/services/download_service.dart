//
import 'dart:async';

import 'package:pl_image_downloader/src/models/download_configuration.dart';
import 'package:pl_image_downloader/src/models/download_info.dart';
import 'package:pl_image_downloader/src/models/download_task.dart';

import '../models/download_event_bridge.dart';
import '../utils/logger.dart';
import 'channel/download_channel.dart';
import 'channel/stream_download_channel.dart';

/// Download Service
/// This class is used to handle the download service.
class DownloadService {
  static const String tag = "download_service";

  DownloadConfiguration? _downloadConfiguration;

  ///Constructor
  DownloadService({DownloadConfiguration? downloadConfiguration}) {
    _downloadConfiguration = downloadConfiguration;
  }

  ///The map of the download task controllers.
  ///The key is the id of the download task.
  ///The value is the stream controller of the download task.
  final Map<int, StreamController<DownloadTask>> _downloadTaskControllers = {};
  final Map<int, DownloadTask> _downloadTasks = {};

  bool _isSetUp = false;

  ///Get the stream of the download task.
  ///@param id The id of the download task.
  ///@return The stream of the download task.
  Stream<DownloadTask> getStream(int id) async* {
    if (!_downloadTaskControllers.containsKey(id)) {
      _downloadTaskControllers[id] = StreamController<DownloadTask>();
    }

    yield* _downloadTaskControllers[id]!.stream;
  }

  DownloadTask? getTask(int id) => _downloadTasks[id];

  ///Update the download task.
  ///@param id The id of the download task.
  void updateTask(int id, DownloadTask task) {
    if (_downloadTasks.containsKey(id)) {
      _downloadTasks[id] = task;
    }
    _downloadTaskControllers[id]?.add(task);
  }

  ///Init the download service
  ///This method is used to initialize the download service.
  ///@return A future that completes when the download service is initialized.
  ///@throws Exception if the download service fails to initialize.
  Future<void> init() async {
    if (_isSetUp) {
      Logger.i(tag, "Download service already initialized");
      return;
    }

    try {
      await DownloadChannel.initDownloadConfig(_downloadConfiguration!);

      await StreamDownloadChannel.setCallBack((eventBridge) {
        switch (eventBridge) {
          case DownloadProgressEventBridge():
            final id = eventBridge.id;
            if (id == null) {
              Logger.e(tag, "Download progress event bridge id is null");
              return;
            }
            final task = getTask(id);
            if (task == null) {
              Logger.e(tag, "Download task not found");
              return;
            }
            updateTask(id, task.copyWith(progress: eventBridge.progress));
            break;
          default:
            break;
        }
      }).listenEventBridge();

      _isSetUp = true;
    } catch (e) {
      Logger.e(tag, e.toString());
      throw Exception(e);
    }
  }

  Future<void> download({required DownloadInfo info}) async {
    if (!_isSetUp) {
      Logger.e(tag, "Download service not initialized");
      throw Exception("Download service not initialized");
    }

    final downloadTask = DownloadTask.fromInfo(info: info);

    _downloadTaskControllers[downloadTask.id]?.add(downloadTask);

    try {
      //TODO: Implement the download logic
    } catch (e) {
      Logger.e(tag, e.toString());
      throw Exception(e);
    }
  }
}
