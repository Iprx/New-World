import 'dart:io' show Platform;

/// Base URL of the FastAPI backend.
///
/// Override at build/run time with:
///   flutter run --dart-define=API_BASE_URL=https://api.example.com
String get apiBaseUrl {
  const override = String.fromEnvironment('API_BASE_URL');
  if (override.isNotEmpty) return override;

  // The Android emulator can't reach the host machine via "localhost";
  // 10.0.2.2 is the emulator's alias for the host loopback interface.
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000';
  }
  return 'http://localhost:8000';
}
