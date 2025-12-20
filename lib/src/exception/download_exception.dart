/// Download Exception
/// This abstract class is used to define the download exception.
abstract class DownloadException implements Exception {
  final String message;

  DownloadException(this.message);

  @override
  String toString() {
    return 'DownloadException: $message';
  }
}

/// Cannot Resume Download Exception
/// This exception is thrown when the download cannot be resumed.
final class CannotResumeDownloadException extends DownloadException {
  CannotResumeDownloadException(super.message);
}

/// Device Not Found Exception
/// This exception is thrown when the device is not found.
final class DeviceNotFoundException extends DownloadException {
  DeviceNotFoundException(super.message);
}

/// File Already Exists Exception
/// This exception is thrown when the file already exists.
final class FileAlreadyExistsException extends DownloadException {
  FileAlreadyExistsException(super.message);
}

/// File Error Exception
/// This exception is thrown when the file error occurs.
final class FileErrorException extends DownloadException {
  FileErrorException(super.message);
}

/// Http Data Error Exception
/// This exception is thrown when the http data error occurs.
final class HttpDataErrorException extends DownloadException {
  HttpDataErrorException(super.message);
}

/// Insufficient Space Exception
/// This exception is thrown when the insufficient space occurs.
final class InsufficientSpaceException extends DownloadException {
  InsufficientSpaceException(super.message);
}

/// Too Many Redirects Exception
/// This exception is thrown when the too many redirects occurs.
final class TooManyRedirectsException extends DownloadException {
  TooManyRedirectsException(super.message);
}

/// Unhandled Http Code Exception
/// This exception is thrown when the unhandled http code occurs.
final class UnhandledHttpCodeException extends DownloadException {
  UnhandledHttpCodeException(super.message);
}

/// Unknown Exception
/// This exception is thrown when the unknown error occurs.
final class UnknownException extends DownloadException {
  UnknownException(super.message);
}
