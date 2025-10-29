import 'dart:developer' as dev;

/// Simple placeholder analytics for MVP.
/// Later you can hook Firebase, Mixpanel, or PostHog.
class Analytics {
  static Future<void> logScreenView(String name) async {
    dev.log('[Analytics] screen_view: $name');
  }
}
