import 'package:flutter/services.dart';

import '../../utils/channel_tag.dart';

/// Download Channel
/// This class is used to handle the download channel for the download service.
class DownloadChannel {
  static final DownloadChannel _instance = DownloadChannel._internal();

  ///Constructor
  DownloadChannel._internal();

  ///Singleton
  static DownloadChannel get instance => _instance;

  ///Method Channel
  static const MethodChannel _methodChannel = MethodChannel(
    ChannelTag.download,
  );
}
