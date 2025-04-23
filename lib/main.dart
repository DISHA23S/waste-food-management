import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';  
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/waste_input_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/restaurant_tracker_screen.dart';
import 'screens/food_transfer_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'localization/app_localizations.dart';
import 'theme.dart';
import 'widgets/watermark_widget.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Load theme preference before the app starts
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final languageCode = prefs.getString('languageCode') ?? 'en';
  
  runApp(MyApp(initialDarkMode: isDarkMode, initialLanguage: languageCode));
}

class MyApp extends StatefulWidget {
  final bool initialDarkMode;
  final String initialLanguage;
  
  const MyApp({
    Key? key, 
    this.initialDarkMode = false, 
    this.initialLanguage = 'en'
  }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool isDarkMode;
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.initialDarkMode;
    _locale = Locale(widget.initialLanguage, '');
  }

  /// Save theme and language settings
  Future<void> _saveSettings({bool? darkMode, String? languageCode}) async {
    final prefs = await SharedPreferences.getInstance();
    if (darkMode != null) {
      await prefs.setBool('isDarkMode', darkMode);
    }
    if (languageCode != null) {
      await prefs.setString('languageCode', languageCode);
    }
  }

  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
    _saveSettings(darkMode: value);
  }

  void changeLanguage(String languageCode) {
    setState(() {
      _locale = Locale(languageCode, '');
    });
    _saveSettings(languageCode: languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: _locale,
      supportedLocales: const [
        Locale('en', ''), 
        Locale('gu', ''), 
        Locale('hi', ''), 
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // Unfocus any focused text field when tapping outside
            FocusScope.of(context).unfocus();
          },
          child: child,
        );
      },
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => WatermarkWidget(child: LoginScreen()),
        '/dashboard': (context) => WatermarkWidget(child: DashboardScreen()),
        '/waste_input': (context) => WatermarkWidget(child: WasteInputScreen()),
        '/reports': (context) => WatermarkWidget(child: ReportsScreen()),
        '/restaurant_tracker': (context) => WatermarkWidget(child: RestaurantTracker()),
        '/food_transfer': (context) => WatermarkWidget(child: FoodTransferScreen()),
        '/profile': (context) => WatermarkWidget(child: ProfileScreen()),
        '/settings': (context) => WatermarkWidget(
          child: SettingsScreen(
            isDarkMode: isDarkMode,
            selectedLanguage: _locale.languageCode,
            onThemeChanged: toggleTheme,
            onLanguageChanged: changeLanguage,
          ),
        ),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasData) {
          return WatermarkWidget(child: DashboardScreen());
        }
        return WatermarkWidget(child: LoginScreen());
      },
    );
  }
}
