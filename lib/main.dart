import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:material_ui/material_ui.dart';

import 'localization/app_localizations.dart';
import 'pages/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  late final ThemeData _lightTheme = _buildTheme(Brightness.light);
  late final ThemeData _darkTheme = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    const radius = BorderRadius.all(Radius.circular(16));
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: brightness,
    );
    final base = ThemeData(colorScheme: scheme);

    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      cardTheme: const CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          textStyle: GoogleFonts.poppins(fontSize: 16),
          shape: const RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) =>
          AppLocalizations(Localizations.localeOf(context)).appTitle,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: _themeMode,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('en'), Locale('tr')],
      home: HomePage(
        onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
      ),
    );
  }
}
