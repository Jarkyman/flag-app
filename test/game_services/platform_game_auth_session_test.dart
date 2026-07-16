import 'dart:async';

import 'package:flag_app/game_services/platform_game_auth_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_services/games_services.dart';

void main() {
  const player = PlayerData(
    playerID: 'player-1',
    displayName: 'Player One',
  );

  test('waits for the authenticated player before reporting connected',
      () async {
    final players = StreamController<PlayerData?>.broadcast();
    final session = PlatformGameAuthSession(
      playerStream: players.stream,
      nativeSignIn: () async {
        players.add(player);
        return 'success';
      },
      playerUpdateTimeout: const Duration(milliseconds: 50),
    );
    final changes = <bool>[];
    final subscription = session.authenticationChanges.listen(changes.add);

    expect(await session.signIn(), isTrue);
    await Future<void>.delayed(Duration.zero);

    expect(session.isSignedIn, isTrue);
    expect(changes, [true]);

    await subscription.cancel();
    await session.dispose();
    await players.close();
  });

  test('recovers when the player stream initially reports an auth error',
      () async {
    final players = StreamController<PlayerData?>.broadcast();
    final session = PlatformGameAuthSession(
      playerStream: players.stream,
      nativeSignIn: () async {
        players
          ..addError(StateError('not authenticated yet'))
          ..add(player);
        return 'success';
      },
      playerUpdateTimeout: const Duration(milliseconds: 50),
    );

    expect(await session.signIn(), isTrue);
    expect(session.isSignedIn, isTrue);
    expect(session.lastError, isNull);

    await session.dispose();
    await players.close();
  });

  test('late authentication is emitted after startup timeout', () async {
    final players = StreamController<PlayerData?>.broadcast();
    final nativeResult = Completer<String?>();
    final session = PlatformGameAuthSession(
      playerStream: players.stream,
      nativeSignIn: () => nativeResult.future,
      authenticationTimeout: const Duration(milliseconds: 10),
      playerUpdateTimeout: Duration.zero,
    );
    final connected = session.authenticationChanges.firstWhere(
      (isSignedIn) => isSignedIn,
    );

    expect(await session.signIn(), isFalse);
    players.add(player);

    expect(await connected, isTrue);
    expect(session.isSignedIn, isTrue);

    nativeResult.complete('success');
    await session.dispose();
    await players.close();
  });

  test('shares one native sign-in attempt between concurrent callers',
      () async {
    final players = StreamController<PlayerData?>.broadcast();
    final nativeResult = Completer<String?>();
    var nativeCalls = 0;
    final session = PlatformGameAuthSession(
      playerStream: players.stream,
      nativeSignIn: () {
        nativeCalls++;
        return nativeResult.future;
      },
    );

    final first = session.signIn();
    final second = session.signIn();
    await Future<void>.delayed(Duration.zero);
    players.add(player);
    nativeResult.complete('success');

    expect(await first, isTrue);
    expect(await second, isTrue);
    expect(nativeCalls, 1);

    await session.dispose();
    await players.close();
  });
}
