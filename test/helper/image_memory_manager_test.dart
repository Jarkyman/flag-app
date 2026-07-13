import 'package:flag_app/helper/image_memory_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('configures a bounded decoded image cache', (tester) async {
    final imageCache = PaintingBinding.instance.imageCache;
    final previousMaximumSize = imageCache.maximumSize;
    final previousMaximumSizeBytes = imageCache.maximumSizeBytes;
    addTearDown(() {
      imageCache.maximumSize = previousMaximumSize;
      imageCache.maximumSizeBytes = previousMaximumSizeBytes;
      imageCache.clear();
      imageCache.clearLiveImages();
    });

    ImageMemoryManager.configureCache();

    expect(imageCache.maximumSize, previousMaximumSize);
    expect(
      imageCache.maximumSizeBytes,
      ImageMemoryManager.maximumCachedImageBytes,
    );
  });
}
