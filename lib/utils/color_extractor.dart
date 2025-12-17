import 'dart:io';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class ColorExtractor {
  static Future<Color> dominantFromFilePath(String? path) async {
    if (path == null) return const Color(0xFF282828);
    final file = File(path);
    if (!await file.exists()) return const Color(0xFF282828);

    final palette = await PaletteGenerator.fromImageProvider(
      FileImage(file),
      maximumColorCount: 12,
    );

    return palette.dominantColor?.color ?? const Color(0xFF282828);
  }
}
