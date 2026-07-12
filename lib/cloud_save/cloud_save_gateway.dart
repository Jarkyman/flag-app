abstract class CloudSaveGateway {
  bool get isSupported;

  Future<void> save({
    required String name,
    required String data,
  });

  Future<Map<String, String>> loadAll({required List<String> names});
}
