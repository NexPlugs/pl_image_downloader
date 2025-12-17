import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pl_image_downloader/pl_image_downloader_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelPlImageDownloader platform = MethodChannelPlImageDownloader();
  const MethodChannel channel = MethodChannel('pl_image_downloader');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
