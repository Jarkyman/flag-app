import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../analytics/analytics_gateway.dart';
import '../models/training_continent.dart';
import '../repos/settings_repo.dart';

class AnalyticsController extends GetxController implements GetxService {
  final AnalyticsGateway gateway;
  final SettingsRepo settingsRepo;

  AnalyticsController({
    required this.gateway,
    required this.settingsRepo,
  });

  bool _isEnabled = true;
  bool get isEnabled => _isEnabled;

  Future<void> initialize() async {
    _isEnabled = await settingsRepo.analyticsSettingRead();
    await _safe(
      () => gateway.setConsent(analyticsStorageGranted: _isEnabled),
    );
    await _safe(() => gateway.setCollectionEnabled(_isEnabled));
  }

  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    await settingsRepo.analyticsSettingsSave(enabled);

    if (enabled) {
      await _safe(
        () => gateway.setConsent(analyticsStorageGranted: true),
      );
      await _safe(() => gateway.setCollectionEnabled(true));
    } else {
      await _safe(() => gateway.setCollectionEnabled(false));
      await _safe(
        () => gateway.setConsent(analyticsStorageGranted: false),
      );
      await _safe(gateway.resetAnalyticsData);
    }
    update();
  }

  Future<void> updateAppContext({
    required String language,
    required bool adsRemoved,
  }) async {
    if (!_isEnabled) return;
    await _safe(
      () => gateway.setUserProperty(name: 'app_language', value: language),
    );
    await _safe(
      () => gateway.setUserProperty(
        name: 'ads_removed',
        value: adsRemoved ? 'yes' : 'no',
      ),
    );
  }

  Future<void> updateLanguage(String language) {
    if (!_isEnabled) return Future.value();
    return _safe(
      () => gateway.setUserProperty(name: 'app_language', value: language),
    );
  }

  Future<void> logScreenView(String routeName) {
    final screenName = _screenName(routeName);
    return _log(() => gateway.logScreenView(screenName));
  }

  Future<void> gameStarted({
    required String gameMode,
    TrainingContinent? continent,
  }) {
    return logEvent(
      'game_started',
      parameters: {
        'game_mode': gameMode,
        if (continent != null) 'continent': continent.id,
      },
    );
  }

  Future<void> answerSubmitted({
    required String gameMode,
    required bool correct,
    required int streak,
    required bool usedHint,
    TrainingContinent? continent,
    bool newRecord = false,
  }) {
    return logEvent(
      'answer_submitted',
      parameters: {
        'game_mode': gameMode,
        'correct': correct,
        'streak': streak,
        'used_hint': usedHint,
        'new_record': newRecord,
        if (continent != null) 'continent': continent.id,
      },
    );
  }

  Future<void> gameFinished({
    required String gameMode,
    required int score,
    required bool newRecord,
    required String reason,
    TrainingContinent? continent,
  }) {
    return logEvent(
      'game_finished',
      parameters: {
        'game_mode': gameMode,
        'score': score,
        'new_record': newRecord,
        'reason': reason,
        if (continent != null) 'continent': continent.id,
      },
    );
  }

  Future<void> continentSelected({
    required String gameMode,
    required TrainingContinent continent,
  }) {
    return logEvent(
      'continent_selected',
      parameters: {
        'game_mode': gameMode,
        'continent': continent.id,
      },
    );
  }

  Future<void> hintUsed({
    required String gameMode,
    required String hintType,
    required int cost,
  }) {
    return logEvent(
      'hint_used',
      parameters: {
        'game_mode': gameMode,
        'hint_type': hintType,
        'cost': cost,
      },
    );
  }

  Future<void> rewardedAdCompleted({required String placement}) {
    return logEvent(
      'rewarded_ad_completed',
      parameters: {'placement': placement},
    );
  }

  Future<void> levelCompleted({
    required String category,
    required int level,
    required String completionMethod,
    required bool firstCompletion,
  }) {
    return logEvent(
      'level_completed',
      parameters: {
        'category': category,
        'level': level,
        'completion_method': completionMethod,
        'first_completion': firstCompletion,
      },
    );
  }

  Future<void> purchaseCompleted({required String productId}) {
    return logEvent(
      'purchase_completed',
      parameters: {'product_id': productId},
    );
  }

  Future<void> purchaseFailed({
    required String productId,
    required String reason,
  }) {
    return logEvent(
      'purchase_failed',
      parameters: {'product_id': productId, 'reason': reason},
    );
  }

  Future<void> gameServicesAuthentication({
    required String platform,
    required String status,
    required String source,
  }) {
    return logEvent(
      'game_services_auth',
      parameters: {
        'platform': platform,
        'status': status,
        'source': source,
      },
    );
  }

  Future<void> gameServicesOverlay({
    required String platform,
    required String overlay,
  }) {
    return logEvent(
      'game_services_overlay',
      parameters: {'platform': platform, 'overlay': overlay},
    );
  }

  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) {
    final safeParameters = <String, Object>{};
    for (final entry in parameters.entries) {
      if (_blockedParameterNames.contains(entry.key)) continue;
      final value = entry.value;
      if (value is bool) {
        safeParameters[entry.key] = value ? 1 : 0;
      } else if (value is num) {
        safeParameters[entry.key] = value;
      } else if (value is String) {
        safeParameters[entry.key] =
            value.length <= 100 ? value : value.substring(0, 100);
      }
    }
    return _log(
      () => gateway.logEvent(name: name, parameters: safeParameters),
    );
  }

  Future<void> _log(Future<void> Function() operation) async {
    if (!_isEnabled) return;
    await _safe(operation);
  }

  Future<void> _safe(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (error, stackTrace) {
      debugPrint('Analytics operation failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  String _screenName(String routeName) {
    if (routeName == '/') return 'home';
    final normalized = routeName
        .replaceFirst(RegExp(r'^/+'), '')
        .replaceAll(RegExp('[^a-zA-Z0-9_]+'), '_');
    return normalized.isEmpty ? 'unknown' : normalized;
  }

  static const Set<String> _blockedParameterNames = {
    'user_id',
    'email',
    'phone',
    'name',
    'display_name',
  };
}
