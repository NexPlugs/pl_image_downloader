import 'package:flutter/services.dart';
import 'package:pl_image_downloader/src/utils/logger.dart';

import '../../models/download_event_bridge.dart';
import '../../utils/channel_tag.dart';

class StreamDownloadChannel {
  static const String _tag = 'eventBridge';

  ///Singleton
  static final StreamDownloadChannel _instance =
      StreamDownloadChannel._internal();

  ///Constructor
  StreamDownloadChannel._internal();

  ///Singleton
  static StreamDownloadChannel get instance => _instance;

  // Service Channel
  final MethodChannel _serviceChannel = MethodChannel(
    ChannelTag.serviceChannel,
  );

  Function(DownloadEventBridge)? _callBack;

  /// Set Call Back
  factory StreamDownloadChannel.setCallBack(
    Function(DownloadEventBridge) callBack,
  ) {
    instance._callBack = callBack;
    return instance;
  }

  /// Listen Event Bridge

  /// Listen Event Bridge
  Future<void> listenEventBridge() async {
    try {
      _serviceChannel.setMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method != ChannelTag.eventBridge) return;

        final json = methodCall.arguments as Map<String, dynamic>;

        final eventBridge = DownloadEventBridge.fromValue(json);

        _callBack?.call(eventBridge);
      });
    } catch (e) {
      Logger.e(_tag, e.toString());
    }
  }
}
