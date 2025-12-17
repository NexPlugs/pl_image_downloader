import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pl_image_downloader_platform_interface.dart';

/// An implementation of [PlImageDownloaderPlatform] that uses method channels.
class MethodChannelPlImageDownloader extends PlImageDownloaderPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pl_image_downloader');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
