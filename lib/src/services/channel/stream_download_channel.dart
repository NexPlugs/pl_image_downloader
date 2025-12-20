class StreamDownloadChannel {
  ///Singleton
  static final StreamDownloadChannel _instance =
      StreamDownloadChannel._internal();

  ///Constructor
  StreamDownloadChannel._internal();

  ///Singleton
  static StreamDownloadChannel get instance => _instance;
}
