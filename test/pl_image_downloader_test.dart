import 'package:flutter_test/flutter_test.dart';
import 'package:pl_image_downloader/pl_image_downloader.dart';
import 'package:pl_image_downloader/pl_image_downloader_platform_interface.dart';
import 'package:pl_image_downloader/pl_image_downloader_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPlImageDownloaderPlatform
    with MockPlatformInterfaceMixin
    implements PlImageDownloaderPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PlImageDownloaderPlatform initialPlatform = PlImageDownloaderPlatform.instance;

  test('$MethodChannelPlImageDownloader is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPlImageDownloader>());
  });

  test('getPlatformVersion', () async {
    PlImageDownloader plImageDownloaderPlugin = PlImageDownloader();
    MockPlImageDownloaderPlatform fakePlatform = MockPlImageDownloaderPlatform();
    PlImageDownloaderPlatform.instance = fakePlatform;

    expect(await plImageDownloaderPlugin.getPlatformVersion(), '42');
  });
}
