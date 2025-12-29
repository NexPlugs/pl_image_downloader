import 'package:flutter/material.dart';
import 'dart:async';
import 'package:pl_image_downloader/pl_image_downloader.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late DownloadService _downloadService;
  bool _isInitialized = true;
  bool _isDownloading = false;
  int _downloadProgress = 0;
  String _statusMessage = 'Ready to download';
  DownloadResult? _lastDownloadResult;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _initializeDownloadService();
  }

  /// Initialize the download service
  Future<void> _initializeDownloadService() async {
    try {
      // Create download configuration
      final config = DownloadConfiguration(
        downloadMode: DownloadMode.normal,
        mimeType: MimeType.imageJpeg,
        downloadDirectory: DownloadDirectory.pictures,
        isExternalStorage: false,
        retryCount: 3,
      );

      // Create and initialize download service
      _downloadService = DownloadService(downloadConfiguration: config);
      await _downloadService.init();

      setState(() {
        _isInitialized = true;

        _statusMessage = 'Download service initialized';
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() {
        _statusMessage = 'Failed to initialize: $e';
      });
    }
  }

  /// Download an image with progress tracking
  Future<void> _downloadImage(String url, {String? fileName}) async {
    if (!_isInitialized) {
      setState(() {
        _statusMessage = 'Please wait for initialization';
      });
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
      _statusMessage = 'Starting download...';
    });

    try {
      // Start download
      final result = await _downloadService.download(
        url: url,
        fileName: fileName,
      );

      setState(() {
        _isDownloading = false;
        _downloadProgress = 100;
        _statusMessage = 'Download completed!';
        _lastDownloadResult = result;
      });

      // Show success message
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Downloaded to: ${result?.path ?? 'Unknown path'}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _downloadProgress = 0;
        _statusMessage = 'Download failed: $e';
      });

      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Image Downloader Example'),
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _isInitialized
                                ? Icons.check_circle
                                : Icons.error_outline,
                            color: _isInitialized
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _statusMessage,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Progress Indicator
              if (_isDownloading)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: _downloadProgress / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('$_downloadProgress%'),
                      ],
                    ),
                  ),
                ),

              // Download Result
              if (_lastDownloadResult != null)
                Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Download Result',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text('File: ${_lastDownloadResult!.fileName}'),
                        Text('Path: ${_lastDownloadResult!.path}'),
                        Text(
                          'Directory: ${_lastDownloadResult!.directoryResult}',
                        ),
                      ],
                    ),
                  ),
                ),

              const Spacer(),

              // Download Buttons
              ElevatedButton.icon(
                onPressed: _isInitialized && !_isDownloading
                    ? () => _downloadImage(
                        'https://images.pexels.com/photos/35368876/pexels-photo-35368876.jpeg',
                        fileName:
                            'sample_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
                      )
                    : null,
                icon: const Icon(Icons.download),
                label: const Text('Download Sample Image'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _isInitialized && !_isDownloading
                    ? () => _downloadImage(
                        'https://thanhtay.edu.vn/wp-content/uploads/2021/07/link-full-tai-truyen-tranh-doremon.jpg',
                        fileName:
                            'placeholder_${DateTime.now().millisecondsSinceEpoch}.jpg',
                      )
                    : null,
                icon: const Icon(Icons.image),
                label: const Text('Download Placeholder Image'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isInitialized && !_isDownloading
                    ? () {
                        setState(() {
                          _lastDownloadResult = null;
                          _downloadProgress = 0;
                          _statusMessage = 'Ready to download';
                        });
                      }
                    : null,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
