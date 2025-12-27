import 'package:flutter/services.dart';
import 'package:pl_image_downloader/src/models/download_info.dart';
import 'package:pl_image_downloader/src/utils/logger.dart';

import '../../models/download_configuration.dart';
import '../../models/download_result.dart';
import '../../utils/channel_tag.dart';

/// Download Channel
/// This class is used to handle the download channel for the download service.
class DownloadChannel {
  static const String tag = "download_channel";

  static final DownloadChannel _instance = DownloadChannel._internal();

  ///Constructor
  DownloadChannel._internal();

  ///Singleton
  static DownloadChannel get instance => _instance;

  ///Method Channel
  static const MethodChannel _methodChannel = MethodChannel(
    ChannelTag.serviceChannel,
  );

  ///Init Download Config
  ///This method is used to initialize the download configuration.
  ///@param downloadConfiguration The download configuration.
  ///
  ///NOTE: This method must be called before any other method in the download service.
  static Future<void> initDownloadConfig(
    DownloadConfiguration downloadConfiguration,
  ) async {
    try {
      await _methodChannel.invokeMethod(
        ChannelTag.initDownloadConfig,
        downloadConfiguration.toJson(),
      );
    } catch (e) {
      Logger.e(tag, e.toString());
      throw Exception(e);
    }
  }

  ///Download
  ///This method is used to download a file.
  ///@param info The download info.
  static Future<DownloadResult?> download(DownloadInfo info) async {
    try {
      final result = await _methodChannel.invokeMethod(
        ChannelTag.download,
        info.toJson(),
      );
      if (result is Map<String, dynamic>) {
        return DownloadResult.fromJson(result);
      }

      return null;
    } catch (e) {
      Logger.e(tag, e.toString());
      throw Exception(e);
    }
  }
}
