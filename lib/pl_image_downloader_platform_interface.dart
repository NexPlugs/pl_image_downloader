import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pl_image_downloader_method_channel.dart';

abstract class PlImageDownloaderPlatform extends PlatformInterface {
  /// Constructs a PlImageDownloaderPlatform.
  PlImageDownloaderPlatform() : super(token: _token);

  static final Object _token = Object();

  static PlImageDownloaderPlatform _instance = MethodChannelPlImageDownloader();

  /// The default instance of [PlImageDownloaderPlatform] to use.
  ///
  /// Defaults to [MethodChannelPlImageDownloader].
  static PlImageDownloaderPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PlImageDownloaderPlatform] when
  /// they register themselves.
  static set instance(PlImageDownloaderPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
