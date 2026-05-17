import 'package:flutter/foundation.dart';

/// Feature flags tied to build mode (not [Env.demoMode]).
abstract final class AppFeatures {
  /// Super admin UI, routes, and redeem — debug builds only.
  static bool get superAdminEnabled => kDebugMode;
}
