import 'dart:io';

import 'package:flag_app/helper/image_decode_size.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all raster assets stay within the dimension limit', () {
    final rasterFiles = Directory('assets')
        .listSync(recursive: true)
        .whereType<File>()
        .where(_isRasterFile)
        .toList();

    expect(rasterFiles, isNotEmpty);

    final oversizedAssets = <String>[];
    for (final file in rasterFiles) {
      final dimensions = _readRasterDimensions(file);
      if (dimensions.width > maximumRasterAssetDimension ||
          dimensions.height > maximumRasterAssetDimension) {
        oversizedAssets.add(
          '${file.path}: ${dimensions.width}x${dimensions.height}',
        );
      }
    }

    expect(
      oversizedAssets,
      isEmpty,
      reason: 'Oversized assets:\n${oversizedAssets.join('\n')}',
    );
  });

  test('raster assets contain no removable image metadata', () {
    const removableMetadataChunks = <String>{
      'eXIf',
      'tEXt',
      'zTXt',
      'iTXt',
      'tIME',
      'pHYs',
    };
    final rasterFiles = Directory('assets')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.toLowerCase().endsWith('.png'));
    final metadataAssets = <String>[];

    for (final file in rasterFiles) {
      final chunks = _readPngChunkNames(file);
      final metadata = chunks.intersection(removableMetadataChunks);
      if (metadata.isNotEmpty) {
        metadataAssets.add('${file.path}: ${metadata.join(', ')}');
      }
    }

    expect(
      metadataAssets,
      isEmpty,
      reason: 'Assets with removable metadata:\n${metadataAssets.join('\n')}',
    );
  });

  test('game images use WebP except for the cloud save cover', () {
    final pngFiles = Directory('assets/image')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.toLowerCase().endsWith('.png'))
        .map((file) => file.path)
        .toList();

    expect(
      pngFiles,
      ['assets/image/flag_ball_cloud_save.png'],
    );
  });
}

bool _isRasterFile(File file) {
  final path = file.path.toLowerCase();
  return path.endsWith('.png') ||
      path.endsWith('.jpg') ||
      path.endsWith('.jpeg') ||
      path.endsWith('.webp');
}

Set<String> _readPngChunkNames(File file) {
  final handle = file.openSync();
  try {
    final signature = handle.readSync(8);
    if (signature.length < 8 ||
        !_startsWith(
          signature,
          const <int>[137, 80, 78, 71, 13, 10, 26, 10],
        )) {
      return const <String>{};
    }

    final chunks = <String>{};
    while (handle.positionSync() + 12 <= handle.lengthSync()) {
      final chunkLength = _readUint32(handle);
      final chunkTypeBytes = handle.readSync(4);
      if (chunkTypeBytes.length != 4) {
        throw FormatException('Invalid PNG chunk header', file.path);
      }

      final chunkType = String.fromCharCodes(chunkTypeBytes);
      chunks.add(chunkType);
      handle.setPositionSync(handle.positionSync() + chunkLength + 4);
      if (chunkType == 'IEND') break;
    }
    return chunks;
  } finally {
    handle.closeSync();
  }
}

({int width, int height}) _readRasterDimensions(File file) {
  final handle = file.openSync();
  try {
    final header = handle.readSync(30);
    if (header.length >= 24 &&
        _startsWith(header, const <int>[137, 80, 78, 71, 13, 10, 26, 10])) {
      return (
        width: _uint32(header, 16),
        height: _uint32(header, 20),
      );
    }

    if (header.length >= 2 && header[0] == 0xff && header[1] == 0xd8) {
      handle.setPositionSync(2);
      return _readJpegDimensions(handle, file.path);
    }

    if (header.length >= 25 &&
        String.fromCharCodes(header.take(4)) == 'RIFF' &&
        String.fromCharCodes(header.skip(8).take(4)) == 'WEBP') {
      return _readWebpDimensions(header, file.path);
    }

    throw FormatException('Unsupported raster format', file.path);
  } finally {
    handle.closeSync();
  }
}

({int width, int height}) _readWebpDimensions(
  List<int> header,
  String path,
) {
  final chunkType = String.fromCharCodes(header.skip(12).take(4));
  if (chunkType == 'VP8L' && header[20] == 0x2f) {
    final bits =
        header[21] | header[22] << 8 | header[23] << 16 | header[24] << 24;
    return (
      width: (bits & 0x3fff) + 1,
      height: ((bits >> 14) & 0x3fff) + 1,
    );
  }
  if (chunkType == 'VP8X' && header.length >= 30) {
    return (
      width: _uint24LittleEndian(header, 24) + 1,
      height: _uint24LittleEndian(header, 27) + 1,
    );
  }

  throw FormatException('Unsupported WebP chunk $chunkType', path);
}

int _uint24LittleEndian(List<int> bytes, int offset) {
  return bytes[offset] | bytes[offset + 1] << 8 | bytes[offset + 2] << 16;
}

({int width, int height}) _readJpegDimensions(
  RandomAccessFile handle,
  String path,
) {
  final fileLength = handle.lengthSync();
  while (handle.positionSync() < fileLength) {
    if (handle.readByteSync() != 0xff) continue;

    var marker = handle.readByteSync();
    while (marker == 0xff) {
      marker = handle.readByteSync();
    }

    if (marker == 0xd9 || marker == 0xda) break;
    if (marker == 0x01 || (marker >= 0xd0 && marker <= 0xd8)) continue;

    final segmentLength = _readUint16(handle);
    if (segmentLength < 2) break;
    if (_isStartOfFrame(marker)) {
      handle.readByteSync();
      final height = _readUint16(handle);
      final width = _readUint16(handle);
      return (width: width, height: height);
    }

    handle.setPositionSync(handle.positionSync() + segmentLength - 2);
  }

  throw FormatException('JPEG dimensions were not found', path);
}

bool _startsWith(List<int> bytes, List<int> signature) {
  for (var index = 0; index < signature.length; index++) {
    if (bytes[index] != signature[index]) return false;
  }
  return true;
}

int _uint32(List<int> bytes, int offset) {
  return bytes[offset] << 24 |
      bytes[offset + 1] << 16 |
      bytes[offset + 2] << 8 |
      bytes[offset + 3];
}

int _readUint16(RandomAccessFile handle) {
  return handle.readByteSync() << 8 | handle.readByteSync();
}

int _readUint32(RandomAccessFile handle) {
  final bytes = handle.readSync(4);
  if (bytes.length != 4) {
    throw const FormatException('Unexpected end of raster file');
  }
  return _uint32(bytes, 0);
}

bool _isStartOfFrame(int marker) {
  return marker == 0xc0 ||
      marker == 0xc1 ||
      marker == 0xc2 ||
      marker == 0xc3 ||
      marker == 0xc5 ||
      marker == 0xc6 ||
      marker == 0xc7 ||
      marker == 0xc9 ||
      marker == 0xca ||
      marker == 0xcb ||
      marker == 0xcd ||
      marker == 0xce ||
      marker == 0xcf;
}
