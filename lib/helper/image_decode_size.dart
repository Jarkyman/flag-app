const int maximumRasterAssetDimension = 1600;

int imageDecodeWidth({
  required double logicalWidth,
  required double devicePixelRatio,
}) {
  final requestedWidth = (logicalWidth * devicePixelRatio).ceil();
  return requestedWidth > maximumRasterAssetDimension
      ? maximumRasterAssetDimension
      : requestedWidth;
}
