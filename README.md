# pl_image_downloader

A powerful Flutter plugin for downloading images with progress tracking, notification support, and background service capabilities.

## Features

- 📥 **Image Download**: Download images from URLs with customizable file names
- 📊 **Progress Tracking**: Real-time download progress updates via streams
- 🔔 **Notification Support**: Display download progress in system notifications (Android)
- 🔄 **Retry Mechanism**: Automatic retry on download failures
- 📁 **Multiple Directories**: Save to different directories (Downloads, Pictures, Music, Movies, Podcasts)
- 🎨 **Multiple Formats**: Support for JPEG, PNG, GIF, SVG, and BMP images
- ⚡ **Concurrent Downloads**: Handle multiple download tasks simultaneously via `DownloadService`
- 🔧 **Background Service**: Download in background service mode (Android only)
- 💾 **Storage Options**: Choose between internal and external storage (Android)

## Platform Support

| Platform | Support | Notes |
|----------|---------|-------|
| **Android** | ✅ Full Support | All features including background service mode |
| **iOS** | ❌ Not Implemented | iOS implementation is not yet available |

### Android Requirements
- Minimum SDK: Not specified (check `build.gradle` for details)
- Permissions: Internet permission (automatically handled)
- Storage permissions: Required for saving files (handled automatically)

### iOS Status
- ⚠️ **iOS is not yet implemented**. The plugin currently only works on Android.
- iOS support is planned for future releases.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  pl_image_downloader: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Usage with Downloader

```dart
import 'package:pl_image_downloader/pl_image_downloader.dart';

// Initialize downloader
final downloader = Downloader();

// Configure download settings
final config = DownloadConfiguration(
  downloadMode: DownloadMode.normal,
  mimeType: MimeType.imageJpeg,
  downloadDirectory: DownloadDirectory.pictures,
  isExternalStorage: false,
  retryCount: 3,
  notificationConfig: NotificationConfig(
    title: 'Downloading Image',
    body: 'Please wait...',
    displayProgress: true,
  ),
);

await downloader.updateConfig(config);

// Watch download progress
downloader.watchProgress((progress) {
  print('Download progress: $progress%');
});

// Download an image
final downloadInfo = DownloadInfo.create(
  url: 'https://example.com/image.jpg',
  fileName: 'my_image.jpg',
);

final result = await downloader.download(downloadInfo);

if (result?.isSuccess == true) {
  print('Downloaded to: ${result?.path}');
} else {
  print('Download failed: ${result?.errorMessage}');
}

// Dispose when done
downloader.dispose();
```

### Advanced Usage with DownloadService

For handling multiple concurrent downloads:

```dart
import 'package:pl_image_downloader/pl_image_downloader.dart';

// Initialize download service
final downloadService = DownloadService();

// Initialize with configuration
await downloadService.init(
  DownloadConfiguration(
    downloadMode: DownloadMode.normal,
    mimeType: MimeType.imagePng,
    downloadDirectory: DownloadDirectory.downloads,
    retryCount: 3,
  ),
);

// Download multiple images
final urls = [
  'https://example.com/image1.jpg',
  'https://example.com/image2.jpg',
  'https://example.com/image3.jpg',
];

for (final url in urls) {
  downloadService.download(
    url: url,
    fileName: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
  ).then((result) {
    if (result?.isSuccess == true) {
      print('Downloaded: ${result?.path}');
    }
  });
  
  // Listen to progress for each download
  final info = DownloadInfo.create(url: url);
  downloadService.listenProgress(info.id, (progress) {
    print('Progress for ${info.id}: $progress%');
  });
}

// Dispose when done
downloadService.dispose();
```

### Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:pl_image_downloader/pl_image_downloader.dart';

class ImageDownloaderExample extends StatefulWidget {
  @override
  _ImageDownloaderExampleState createState() => _ImageDownloaderExampleState();
}

class _ImageDownloaderExampleState extends State<ImageDownloaderExample> {
  late Downloader _downloader;
  int _progress = 0;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _initializeDownloader();
  }

  Future<void> _initializeDownloader() async {
    _downloader = Downloader();
    
    final config = DownloadConfiguration(
      downloadMode: DownloadMode.normal,
      mimeType: MimeType.imageJpeg,
      downloadDirectory: DownloadDirectory.pictures,
      retryCount: 3,
    );
    
    await _downloader.updateConfig(config);
    
    _downloader.watchProgress((progress) {
      setState(() {
        _progress = progress;
      });
    });
  }

  Future<void> _downloadImage() async {
    setState(() {
      _isDownloading = true;
      _progress = 0;
    });

    final result = await _downloader.download(
      DownloadInfo.create(
        url: 'https://example.com/image.jpg',
        fileName: 'downloaded_image.jpg',
      ),
    );

    setState(() {
      _isDownloading = false;
    });

    if (result?.isSuccess == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded to: ${result?.path}')),
      );
    }
  }

  @override
  void dispose() {
    _downloader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Downloader')),
      body: Column(
        children: [
          if (_isDownloading)
            LinearProgressIndicator(value: _progress / 100),
          ElevatedButton(
            onPressed: _isDownloading ? null : _downloadImage,
            child: Text('Download Image'),
          ),
        ],
      ),
    );
  }
}
```

## API Reference

### Downloader

Simple interface for downloading images.

#### Methods

- `download(DownloadInfo downloadInfo)`: Download an image
- `updateConfig(DownloadConfiguration config)`: Update download configuration
- `watchProgress(Function(int progress) callback)`: Watch download progress
- `dispose()`: Dispose the downloader

### DownloadService

Advanced service for handling multiple concurrent downloads.

#### Methods

- `init(DownloadConfiguration? config)`: Initialize the download service
- `download({String? fileName, required String url})`: Download an image
- `downloadConfig(DownloadConfiguration config)`: Update configuration
- `listenProgress(int id, void Function(int progress) callback)`: Listen to progress
- `getStream(int id)`: Get download task stream
- `getTask(int id)`: Get download task
- `dispose()`: Dispose the service

### DownloadConfiguration

Configuration for download behavior.

#### Properties

- `saveName`: Optional custom file name
- `isExternalStorage`: Save to external storage (Android)
- `downloadMode`: Download mode (`DownloadMode.normal` or `DownloadMode.runningBackgroundService`)
- `mimeType`: MIME type of the image
- `notificationConfig`: Notification configuration
- `retryCount`: Number of retry attempts (default: 3)
- `downloadDirectory`: Target directory for saving

### DownloadInfo

Information about a download request.

#### Factory

- `DownloadInfo.create({required String url, String? fileName})`: Create download info

### DownloadResult

Result of a download operation.

#### Properties

- `path`: File path of downloaded image
- `fileName`: Name of the downloaded file
- `directoryResult`: Directory where file was saved
- `isSuccess`: Whether download was successful
- `errorMessage`: Error message if download failed

## Enums

### DownloadMode

- `normal`: Standard download mode
- `runningBackgroundService`: Background service mode (Android only)

### DownloadDirectory

- `downloads`: Downloads directory
- `pictures`: Pictures directory
- `music`: Music directory
- `movies`: Movies directory
- `podcasts`: Podcasts directory

### MimeType

- `imageJpeg`: JPEG images
- `imagePng`: PNG images
- `imageGif`: GIF images
- `imageSvgXml`: SVG images
- `imageBmp`: BMP images

## Notes

- ⚠️ **iOS is not yet implemented** - This plugin currently only works on Android
- Background service mode (`DownloadMode.runningBackgroundService`) is only available on Android
- External storage option (`isExternalStorage`) is Android-specific
- Make sure to dispose `Downloader` or `DownloadService` instances when done to free resources
- The plugin handles permissions automatically, but ensure your app has the necessary permissions in `AndroidManifest.xml`

## License

See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
