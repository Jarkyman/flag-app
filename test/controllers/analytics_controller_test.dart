import 'package:flag_app/analytics/analytics_gateway.dart';
import 'package:flag_app/controllers/analytics_controller.dart';
import 'package:flag_app/helper/app_constants.dart';
import 'package:flag_app/models/training_continent.dart';
import 'package:flag_app/repos/settings_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAnalyticsGateway gateway;
  late SharedPreferences preferences;
  late AnalyticsController controller;

  Future<void> createController({Map<String, Object> values = const {}}) async {
    SharedPreferences.setMockInitialValues(values);
    preferences = await SharedPreferences.getInstance();
    gateway = FakeAnalyticsGateway();
    controller = AnalyticsController(
      gateway: gateway,
      settingsRepo: SettingsRepo(sharedPreferences: preferences),
    );
  }

  test('analytics is enabled by default with advertising consent denied',
      () async {
    await createController();

    await controller.initialize();

    expect(controller.isEnabled, isTrue);
    expect(gateway.consentValues, [true]);
    expect(gateway.collectionValues, [true]);
  });

  test('saved opt-out is applied before any custom event is sent', () async {
    await createController(
      values: {AppConstants.ANALYTICS_ENABLED: false},
    );

    await controller.initialize();
    await controller.gameStarted(
      gameMode: 'find_flag',
      continent: TrainingContinent.europe,
    );

    expect(controller.isEnabled, isFalse);
    expect(gateway.consentValues, [false]);
    expect(gateway.collectionValues, [false]);
    expect(gateway.events, isEmpty);
  });

  test('opting out disables collection, revokes consent and resets the id',
      () async {
    await createController();
    await controller.initialize();

    await controller.setEnabled(false);

    expect(
      preferences.getBool(AppConstants.ANALYTICS_ENABLED),
      isFalse,
    );
    expect(gateway.collectionValues, [true, false]);
    expect(gateway.consentValues, [true, false]);
    expect(gateway.resetCount, 1);
  });

  test('events contain stable non-personal parameters only', () async {
    await createController();
    await controller.initialize();

    await controller.logEvent(
      'test_event',
      parameters: {
        'correct': true,
        'score': 7,
        'game_mode': 'find_flag',
        'email': 'not-allowed@example.com',
        'user_id': 'not-allowed',
        'long_value': List.filled(120, 'x').join(),
      },
    );

    expect(gateway.events, hasLength(1));
    expect(gateway.events.single.name, 'test_event');
    expect(
      gateway.events.single.parameters,
      {
        'correct': 1,
        'score': 7,
        'game_mode': 'find_flag',
        'long_value': List.filled(100, 'x').join(),
      },
    );
  });

  test('route names are normalized before screen tracking', () async {
    await createController();
    await controller.initialize();

    await controller.logScreenView('/game-services-page');
    await controller.logScreenView('/');

    expect(gateway.screenViews, ['game_services_page', 'home']);
  });

  test('analytics failures never escape into gameplay', () async {
    await createController();
    await controller.initialize();
    gateway.throwOnEvent = true;

    await expectLater(
      controller.answerSubmitted(
        gameMode: 'which_country',
        correct: false,
        streak: 3,
        usedHint: false,
      ),
      completes,
    );
  });
}

class FakeAnalyticsGateway implements AnalyticsGateway {
  final List<bool> consentValues = [];
  final List<bool> collectionValues = [];
  final List<RecordedAnalyticsEvent> events = [];
  final List<String> screenViews = [];
  final Map<String, String?> userProperties = {};
  int resetCount = 0;
  bool throwOnEvent = false;

  @override
  Future<void> setConsent({required bool analyticsStorageGranted}) async {
    consentValues.add(analyticsStorageGranted);
  }

  @override
  Future<void> setCollectionEnabled(bool enabled) async {
    collectionValues.add(enabled);
  }

  @override
  Future<void> resetAnalyticsData() async {
    resetCount++;
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    userProperties[name] = value;
  }

  @override
  Future<void> logEvent({
    required String name,
    required Map<String, Object> parameters,
  }) async {
    if (throwOnEvent) throw StateError('Analytics unavailable');
    events.add(RecordedAnalyticsEvent(name, parameters));
  }

  @override
  Future<void> logScreenView(String screenName) async {
    screenViews.add(screenName);
  }
}

class RecordedAnalyticsEvent {
  final String name;
  final Map<String, Object> parameters;

  RecordedAnalyticsEvent(this.name, this.parameters);
}
