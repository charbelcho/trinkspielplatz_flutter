import 'package:firebase_analytics/firebase_analytics.dart';

class Analytics {
  Analytics(this.analytics, this.observer);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  void logEvent(String eventName, Map<String, dynamic> params) {
    // log any analytics here.
  }
}