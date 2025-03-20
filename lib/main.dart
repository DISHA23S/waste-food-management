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

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;
  Locale _locale = const Locale('en', ''); // Default is English

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Load saved theme and language settings
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _locale = Locale(prefs.getString('languageCode') ?? 'en', '');
    });
  }

  /// Save theme and language settings
  Future<void> _saveSettings({bool? darkMode, String? languageCode}) async {
    final prefs = await SharedPreferences.getInstance();
    if (darkMode != null) prefs.setBool('isDarkMode', darkMode);
    if (languageCode != null) prefs.setString('languageCode', languageCode);
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
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
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
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/waste_input': (context) => WasteInputScreen(),
        '/reports': (context) => ReportsScreen(),
        '/restaurant_tracker': (context) => RestaurantTracker(),
        '/food_transfer': (context) => TransferScreen(),
        '/profile': (context) => ProfileScreen(),
        '/settings': (context) => SettingsScreen(
              isDarkMode: isDarkMode,
              selectedLanguage: _locale.languageCode,
              onThemeChanged: toggleTheme,
              onLanguageChanged: changeLanguage,
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
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return DashboardScreen();
        }
        return LoginScreen();
      },
    );
  }
}
