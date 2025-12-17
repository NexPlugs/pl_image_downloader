
import 'pl_image_downloader_platform_interface.dart';

class PlImageDownloader {
  Future<String?> getPlatformVersion() {
    return PlImageDownloaderPlatform.instance.getPlatformVersion();
  }
}
