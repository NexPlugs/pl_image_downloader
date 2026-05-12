import 'package:flutter/services.dart';
import 'package:pl_image_downloader/src/models/download_info.dart';
import 'package:pl_image_downloader/src/services/platform_permission.dart';
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
    final method = ChannelTag.initDownloadConfig;
    if (!PlatformPermission.checkPermission(method)) {
      throw Exception("This method don't support for your device $method");
    }
    try {
      await _methodChannel.invokeMethod(method, downloadConfiguration.toJson());
    } catch (e) {
      Logger.e(tag, e.toString());
      throw Exception(e);
    }
  }

  ///Download Config
  ///This method is used to download the configuration.
  ///@param donwloadConfiguration The download configuration.
  ///@return A future that completes when the configuration is downloaded.
  ///@throws Exception if the configuration fails to download.
  static Future<bool> downloadConfig(
    DownloadConfiguration donwloadConfiguration,
  ) async {
    final method = ChannelTag.downloadConfig;
    if (!PlatformPermission.checkPermission(method)) {
      throw Exception("This method don't support for your device $method");
    }
    try {
      final result = await _methodChannel.invokeMethod(
        method,
        donwloadConfiguration.toJson(),
      );
      if (result is bool) {
        return result;
      }
      return false;
    } catch (e) {
      Logger.e(tag, e.toString());
      throw Exception(e);
    }
  }

  ///Service Dispose
  ///This method is used to dispose the service.
  ///@throws Exception if the service fails to dispose.
  static Future<void> serviceDispose() async {
    try {
      await _methodChannel.invokeMethod(ChannelTag.serviceDisposeTag);
    } catch (e) {
      Logger.e(tag, e.toString());
      throw Exception(e);
    }
  }

  ///Download
  ///This method is used to download a file.
  ///@param info The download info.
  static Future<DownloadResult?> download(DownloadInfo info) async {
    final method = ChannelTag.download;
    if (!PlatformPermission.checkPermission(method)) {
      throw Exception("This method don't support for your device $method");
    }
    try {
      final result = await _methodChannel.invokeMethod(method, info.toJson());
      if (result is Map) {
        return DownloadResult.fromJson(Map<String, dynamic>.from(result));
      }

      return null;
    } catch (e) {
      Logger.e(tag, e.toString());
      throw Exception(e);
    }
  }

  ///Download Service Tag
  ///This method is used to download the service tag.
  ///@param info The download info.
  static Future<void> downloadServiceTag(DownloadInfo info) async {
    final method = ChannelTag.downloadServiceTag;
    if (!PlatformPermission.checkPermission(method)) {
      throw Exception("This method don't support for your device $method");
    }
    try {
      await _methodChannel.invokeMethod(method, info.toJson());
    } catch (e) {
      Logger.e(tag, e.toString());
      throw Exception(e);
    }
  }

  /// Download Pause
  /// This method is used to pause the download task.
  /// @param id The id of the download task.
  /// @throws Exception if the download task fails to pause.
  static Future<void> downloadPause(int id) async {
    final method = ChannelTag.downloadPause;
    if (!PlatformPermission.checkPermission(method)) {
      throw Exception("This method don't support for your device $method");
    }
    try {
      await _methodChannel.invokeMethod(method, {"id": id});
    } catch (e) {
      Logger.e(tag, e.toString());
      throw Exception(e);
    }
  }

  /// Download Resume
  /// This method is used to resume the download task.
  /// @param id The id of the download task.
  /// @throws Exception if the download task fails to resume.
  static Future<void> downloadResume(int id) async {
    final method = ChannelTag.downloadResume;
    if (!PlatformPermission.checkPermission(method)) {
      throw Exception("This method don't support for your device $method");
    }
    try {
      await _methodChannel.invokeMethod(method, {"id": id});
    } catch (e) {
      Logger.e(tag, e.toString());
      throw Exception(e);
    }
  }

  /// Download Cancel
  /// This method is used to cancel the download task.
  /// @param id The id of the download task.
  /// @throws Exception if the download task fails to cancel.
  static Future<void> downloadCancel(int id) async {
    final method = ChannelTag.downloadCancel;
    if (!PlatformPermission.checkPermission(method)) {
      throw Exception("This method don't support for your device $method");
    }
    try {
      await _methodChannel.invokeMethod(method, {"id": id});
    } catch (e) {
      Logger.e(tag, e.toString());
      throw Exception(e);
    }
  }
}
