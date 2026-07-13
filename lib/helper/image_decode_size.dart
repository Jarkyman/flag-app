int imageDecodeWidth({
  required double logicalWidth,
  required double devicePixelRatio,
}) {
  return (logicalWidth * devicePixelRatio).ceil();
}
