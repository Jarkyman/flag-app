import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:games_services/games_services.dart';

import 'cloud_save_gateway.dart';

class PlatformCloudSaveGateway implements CloudSaveGateway {
  @override
  bool get isSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  Future<void> save({
    required String name,
    required String data,
  }) async {
    // Google Play Games guarantees 800 KB for snapshot cover images. The
    // full-size flag ball is larger than that, so use the dedicated thumbnail
    // to prevent Android commits from being rejected while keeping the artwork.
    final coverImage =
        await rootBundle.load('assets/image/flag_ball_cloud_save.png');
    await SaveGame.saveGame(
      data: data,
      name: name,
      coverImage: coverImage.buffer.asUint8List(),
      description: 'Flags Game progress',
    );
  }

  @override
  Future<Map<String, String>> loadAll({required List<String> names}) async {
    final saves = await SaveGame.getSavedGames(
      forceRefresh: true,
      ignoreImages: true,
    );
    if (saves == null) return {};

    final existingNames = saves.map((save) => save.name).toSet();
    final result = <String, String>{};
    for (final name in names) {
      if (!existingNames.contains(name)) continue;
      final data = await SaveGame.loadGame(name: name);
      if (data != null && data.trim().isNotEmpty) {
        result[name] = data;
      }
    }
    return result;
  }
}
