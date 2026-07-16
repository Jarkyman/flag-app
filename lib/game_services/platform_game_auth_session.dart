import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:games_services/games_services.dart';

typedef NativeGameSignIn = Future<String?> Function();

/// Keeps one persistent view of the native Game Center / Play Games player.
///
/// The games_services `isSignedIn` helper creates a short-lived player-stream
/// subscription. On Android, the authenticated player can arrive shortly after
/// the native sign-in future completes, so a one-shot check can incorrectly
/// report that the player is disconnected. Keeping the stream open also lets a
/// late platform authentication trigger cloud restore after startup has already
/// continued offline.
class PlatformGameAuthSession {
  PlatformGameAuthSession({
    required Stream<PlayerData?> playerStream,
    required NativeGameSignIn nativeSignIn,
    this.authenticationTimeout = const Duration(seconds: 8),
    this.playerUpdateTimeout = const Duration(seconds: 1),
  })  : _playerStream = playerStream,
        _nativeSignIn = nativeSignIn;

  static final PlatformGameAuthSession instance = PlatformGameAuthSession(
    playerStream: GameAuth.player,
    nativeSignIn: GameAuth.signIn,
  );

  final Stream<PlayerData?> _playerStream;
  final NativeGameSignIn _nativeSignIn;
  final Duration authenticationTimeout;
  final Duration playerUpdateTimeout;
  final StreamController<bool> _authenticationChanges =
      StreamController<bool>.broadcast();

  StreamSubscription<PlayerData?>? _playerSubscription;
  Future<bool>? _inFlight;
  Completer<void>? _authenticatedPlayer;
  bool _isSignedIn = false;
  String? _lastError;

  bool get isSignedIn => _isSignedIn;
  String? get lastError => _lastError;

  Stream<bool> get authenticationChanges {
    _listenForPlayerChanges();
    return _authenticationChanges.stream;
  }

  Future<bool> signIn() {
    final existing = _inFlight;
    if (existing != null) return existing;

    final attempt = _performSignIn();
    _inFlight = attempt;
    unawaited(
      attempt.whenComplete(() {
        if (identical(_inFlight, attempt)) _inFlight = null;
      }),
    );
    return attempt;
  }

  Future<bool> _performSignIn() async {
    _listenForPlayerChanges();
    await Future<void>.delayed(Duration.zero);

    _lastError = null;
    if (_isSignedIn) return true;

    final authenticatedPlayer = Completer<void>();
    _authenticatedPlayer = authenticatedPlayer;
    try {
      final result = await _nativeSignIn().timeout(authenticationTimeout);

      if (!_isSignedIn) {
        try {
          await authenticatedPlayer.future.timeout(playerUpdateTimeout);
        } on TimeoutException {
          // Report the missing player state below with the native result.
        }
      }

      if (_isSignedIn) return true;

      _lastError =
          'Native authentication returned ${result ?? 'no result'}, but no '
          'authenticated Game Center/Play Games player was received.';
      debugPrint('Game services sign-in failed: $_lastError');
      return false;
    } on PlatformException catch (error) {
      final details = error.details == null ? '' : ' (${error.details})';
      _lastError = '${error.code}: ${error.message ?? 'Unknown error'}$details';
      debugPrint('Game services sign-in failed: $_lastError');
      return false;
    } on TimeoutException catch (error) {
      _lastError = error.toString();
      debugPrint('Game services sign-in timed out: $error');
      return false;
    } catch (error) {
      _lastError = error.toString();
      debugPrint('Game services sign-in failed: $error');
      return false;
    } finally {
      if (identical(_authenticatedPlayer, authenticatedPlayer)) {
        _authenticatedPlayer = null;
      }
    }
  }

  void _listenForPlayerChanges() {
    _playerSubscription ??= _playerStream.listen(
      (player) => _setSignedIn(player != null),
      onError: (Object error) {
        _lastError = error.toString();
        _setSignedIn(false);
        debugPrint('Game services player stream failed: $error');
      },
    );
  }

  void _setSignedIn(bool value) {
    final changed = _isSignedIn != value;
    _isSignedIn = value;
    if (value) {
      _lastError = null;
      final authenticatedPlayer = _authenticatedPlayer;
      if (authenticatedPlayer != null && !authenticatedPlayer.isCompleted) {
        authenticatedPlayer.complete();
      }
    }
    if (changed) _authenticationChanges.add(value);
  }

  @visibleForTesting
  Future<void> dispose() async {
    await _playerSubscription?.cancel();
    await _authenticationChanges.close();
  }
}
