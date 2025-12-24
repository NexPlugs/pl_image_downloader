import 'package:flutter/services.dart';
import 'package:pl_image_downloader/src/utils/logger.dart';

import '../../models/download_configuration.dart';
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
    ChannelTag.download,
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
}
