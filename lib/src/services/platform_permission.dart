import 'dart:io';

import 'package:pl_image_downloader/src/utils/channel_tag.dart';

// Platform Permission is used to define the permissions for the download service on different platforms.
class PlatformPermission {
  static const List<String> androidPermission = [
    ChannelTag.download,
    ChannelTag.downloadConfig,
    ChannelTag.initDownloadConfig,
    ChannelTag.downloadServiceTag,
    ChannelTag.downloadProgress,
  ];

  static const List<String> iosPermission = [
    ChannelTag.download,
    ChannelTag.downloadCancel,
    ChannelTag.downloadPause,
    ChannelTag.downloadResume,
    ChannelTag.initDownloadConfig,
    ChannelTag.downloadProgress,
  ];

  static bool checkPermission(String permission) {
    if (Platform.isAndroid) {
      return androidPermission.contains(permission);
    } else if (Platform.isIOS) {
      return iosPermission.contains(permission);
    }
    return false;
  }
}
