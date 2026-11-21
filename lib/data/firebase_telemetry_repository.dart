import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'telemetry_repository.dart';

/// Firebase implementation of the monitoring contract.
class FirebaseTelemetryRepository implements TelemetryRepository {
  FirebaseTelemetryRepository({
    FirebaseAnalytics? analytics,
    FirebaseCrashlytics? crashlytics,
  }) : _analytics = analytics ?? FirebaseAnalytics.instance,
       _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  final FirebaseAnalytics _analytics;
  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) =>
      _analytics.logEvent(name: name, parameters: parameters);

  @override
  Future<void> logScreenView({
    required String screenName,
    required String screenClass,
  }) => _analytics.logScreenView(
    screenName: screenName,
    screenClass: screenClass,
  );

  @override
  void recordFlutterFatalError(FlutterErrorDetails details) {
    _crashlytics.recordFlutterFatalError(details);
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace stack, {
    required bool fatal,
  }) => _crashlytics.recordError(error, stack, fatal: fatal);
}
