import 'models/cloud_save_data.dart';

abstract class CloudSaveStore {
  DateTime? get lastCloudSaveAt;
  DateTime? get pendingChangeAt;

  CloudSaveData createSnapshot(DateTime savedAtUtc);

  Future<void> restore(CloudSaveData data);

  Future<void> markPendingChanges(DateTime changedAtUtc);

  Future<void> markCloudSaveComplete(DateTime savedAtUtc);

  Future<void> clearPendingChanges();
}
