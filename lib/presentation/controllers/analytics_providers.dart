import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/data/services/analytics_service.dart';

final analyticsServiceProvider = Provider<AnalyticsService>(
  (ref) => AnalyticsService(),
);
