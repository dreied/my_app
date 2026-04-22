import 'package:flutter/services.dart' show rootBundle;

class IconLoader {
  static Future<List<String>> loadIcons() async {
    try {
      final content = await rootBundle.loadString('assets/icons/icons.txt');

      final lines = content
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      return lines;
    } catch (e) {
      print("ERROR loading icons.txt: $e");
      return ["bar.png"]; // fallback
    }
  }
}