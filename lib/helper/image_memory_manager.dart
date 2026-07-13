import 'package:flutter/widgets.dart';

class ImageMemoryManager {
  static const int maximumCachedImageBytes = 48 * 1024 * 1024;

  static void configureCache() {
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.maximumSizeBytes = maximumCachedImageBytes;
  }
}
