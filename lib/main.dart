
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '/generated/app_localizations.dart';
import 'screens/home_page.dart';
import 'services/settings_service.dart';
import 'database/category_dao.dart';
import 'utils/startup_pin_guard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted settings (including language)
  await SettingsService.instance.load();
  await Future.delayed(const Duration(milliseconds: 200));
  await CategoryDao.initializeIcons();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale(SettingsService.instance.language);
  bool _isDark = false;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
      SettingsService.instance.setLanguage(locale.languageCode);
    });
  }

  void toggleTheme(bool value) {
    setState(() {
      _isDark = value;
    });
    SettingsService.instance.setTheme(value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,

      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('ar', 'IQ'),
        Locale('ar', 'SA'),
      ],

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: StartupPinGuard(
        child: HomePage(
          onThemeChanged: toggleTheme,
          isDark: _isDark,
          onLanguageChanged: setLocale,
        ),
      ),
    );
  }
}
