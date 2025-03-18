import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  final bool isDarkMode;
  final String selectedLanguage;
  final Function(bool) onThemeChanged;
  final Function(String) onLanguageChanged;

  SettingsScreen({
    required this.isDarkMode,
    required this.selectedLanguage,
    required this.onThemeChanged,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate("settings") ?? "Settings"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context)?.translate("dark_mode") ?? "Dark Mode"),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                onThemeChanged(value);
              },
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)?.translate("language") ?? "Language"),
            subtitle: Text(selectedLanguage),
            trailing: DropdownButton<String>(
              value: selectedLanguage,
              items: [
                DropdownMenuItem(value: "en", child: Text("English")),
                DropdownMenuItem(value: "gu", child: Text("Gujarati")),
                DropdownMenuItem(value: "hi", child: Text("Hindi")),
              ],
              onChanged: (String? newLanguage) {
                if (newLanguage != null) {
                  onLanguageChanged(newLanguage);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
