import 'package:flutter/foundation.dart';

/// Monitoring contract used by the app. Feature widgets do not depend on
/// Firebase Analytics or Crashlytics directly.
abstract interface class TelemetryRepository {
  Future<void> logEvent(String name, {Map<String, Object>? parameters});
  Future<void> logScreenView({
    required String screenName,
    required String screenClass,
  });
  void recordFlutterFatalError(FlutterErrorDetails details);
  Future<void> recordError(
    Object error,
    StackTrace stack, {
    required bool fatal,
  });
}

class NoopTelemetryRepository implements TelemetryRepository {
  const NoopTelemetryRepository();

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {}

  @override
  Future<void> logScreenView({
    required String screenName,
    required String screenClass,
  }) async {}

  @override
  void recordFlutterFatalError(FlutterErrorDetails details) {}

  @override
  Future<void> recordError(
    Object error,
    StackTrace stack, {
    required bool fatal,
  }) async {}
}
