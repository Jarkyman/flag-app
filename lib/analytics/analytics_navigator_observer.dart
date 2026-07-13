import 'dart:async';

import 'package:flutter/widgets.dart';

import '../controllers/analytics_controller.dart';

class AnalyticsNavigatorObserver extends NavigatorObserver {
  final AnalyticsController controller;

  AnalyticsNavigatorObserver({required this.controller});

  void _log(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (route is PageRoute && name != null) {
      unawaited(controller.logScreenView(name));
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _log(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _log(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _log(previousRoute);
  }
}
