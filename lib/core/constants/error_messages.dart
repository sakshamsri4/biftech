/// Constants for user-friendly error messages
class ErrorMessages {
  /// Private constructor to prevent instantiation
  ErrorMessages._();

  /// Generic error message
  static const String generic = 'Something went wrong. Please try again.';

  /// Network error message
  static const String network = 'Network error. Please check your connection.';

  /// Authentication error message
  static const String auth = 'Authentication error. Please log in again.';

  /// Video loading error message
  static const String videoLoading = 'Unable to load videos. Please try again.';

  /// Video upload error message
  static const String videoUpload = 'Unable to upload video. Please try again.';

  /// Video playback error message
  static const String videoPlayback = 'Unable to play video. Please try again.';

  /// Storage error message
  static const String storage = 'Storage error. Please try again.';

  /// Permission error message
  static const String permission =
      'Permission denied.Please check app permissions.';

  /// Get a user-friendly error message based on the error type
  static String getUserFriendlyMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('connection')) {
      return network;
    } else if (errorString.contains('authentication') ||
        errorString.contains('auth') ||
        errorString.contains('login')) {
      return auth;
    } else if (errorString.contains('video') && errorString.contains('load')) {
      return videoLoading;
    } else if (errorString.contains('video') &&
        errorString.contains('upload')) {
      return videoUpload;
    } else if (errorString.contains('video') && errorString.contains('play')) {
      return videoPlayback;
    } else if (errorString.contains('storage') ||
        errorString.contains('hive') ||
        errorString.contains('box')) {
      return storage;
    } else if (errorString.contains('permission')) {
      return permission;
    } else {
      return generic;
    }
  }
}
