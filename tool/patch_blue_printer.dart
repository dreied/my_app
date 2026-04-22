import 'dart:io';

void main() {
  // Use the correct pub cache path
  final pubCachePath = Platform.environment['PUB_CACHE'] ??
      '${Platform.environment['HOME']}/.pub-cache';
  
  final pluginPath = Directory(
    '$pubCachePath/hosted/pub.dev/blue_thermal_printer-1.2.3/android',
  );

  final gradleFile = File('${pluginPath.path}/build.gradle');

  if (!gradleFile.existsSync()) {
    print('blue_thermal_printer build.gradle not found at: ${gradleFile.path}');
    return;
  }

  String content = gradleFile.readAsStringSync();

  if (!content.contains('namespace')) {
    content = content.replaceFirst(
      'android {',
      'android {\n    namespace "id.kakzaki.blue_thermal_printer"',
    );

    gradleFile.writeAsStringSync(content);
    print('Namespace added to blue_thermal_printer.');
  } else {
    print('Namespace already exists.');
  }
}
