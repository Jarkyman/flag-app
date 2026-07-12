abstract class CloudSaveSession {
  bool get isSignedIn;

  Future<void> signIn();

  Future<void> syncStoredProgress();
}
