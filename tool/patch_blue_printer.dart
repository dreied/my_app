import 'dart:io';

void main() {
  // GitHub Actions PUB_CACHE path
  final pluginPath = Directory(
    '/home/runner/.pub-cache/hosted/pub.dev/blue_thermal_printer-1.2.3/android',
  );

  if (!pluginPath.existsSync()) {
    print('❌ Plugin directory not found: ${pluginPath.path}');
    return;
  }

  final gradleFile = File('${pluginPath.path}/build.gradle');

  if (!gradleFile.existsSync()) {
    print('❌ build.gradle not found in plugin.');
    return;
  }

  String content = gradleFile.readAsStringSync();

  if (content.contains('namespace')) {
    print('✔ Namespace already exists. No patch needed.');
    return;
  }

  content = content.replaceFirst(
    'android {',
    'android {\n    namespace "id.kakzaki.blue_thermal_printer"',
  );

  gradleFile.writeAsStringSync(content);

  print('✔ Namespace successfully added to blue_thermal_printer.');
}
