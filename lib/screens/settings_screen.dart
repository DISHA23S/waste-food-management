import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
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
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Color primaryColor = Color(0xFF40B59F);
  final Color secondaryColor = Color(0xFF3AA391);
  late Color backgroundColor;
  late Color textColor;
  late Color cardColor;
  late Color subtitleColor;
  late Color dividerColor;
  User? user = FirebaseAuth.instance.currentUser;
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _updateThemeColors();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  void _updateThemeColors() {
    if (_isDarkMode) {
      // Dark theme colors
      backgroundColor = Color(0xFF121212);
      cardColor = Color(0xFF1E1E1E);
      textColor = Colors.white;
      subtitleColor = Colors.grey[300]!;
      dividerColor = Colors.white.withOpacity(0.2);
    } else {
      // Light theme colors
      backgroundColor = Color(0xFFF7FAFC);
      cardColor = Colors.white;
      textColor = Color(0xFF2D3748);
      subtitleColor = Color(0xFF64748B);
      dividerColor = Colors.grey.withOpacity(0.2);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      drawer: _buildDrawer(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(200),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                primaryColor,
                secondaryColor,
              ],
            ),
            borderRadius: BorderRadius.zero,
          ),
          child: Stack(
            children: [
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                left: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                right: 100,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(
                        icon: Icon(Icons.menu, color: Colors.white, size: 28),
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 50, right: 24, top: 80, bottom: 0),
                      child: Text(
                        AppLocalizations.of(context)?.translate("settings") ?? "Settings",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: primaryColor,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.zero,
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - kToolbarHeight - MediaQuery.of(context).padding.top),
              child: Column(
                children: [
                  Expanded(
                    child: _buildSettingsContent(context),
                  ),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: _isDarkMode ? Color(0xFF1E1E1E) : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.zero,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 25,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: EdgeInsets.only(top: 50, bottom: 24, left: 20, right: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    primaryColor,
                    secondaryColor,
                  ],
                ),
                borderRadius: BorderRadius.zero,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? Icon(
                              Icons.person,
                              size: 32,
                              color: primaryColor,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    user?.displayName ?? "User",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  _buildNavItem(context, "Dashboard", Icons.dashboard_outlined, Icons.dashboard, '/dashboard', false),
                  _buildNavItem(context, "Input Waste", Icons.add_circle_outline, Icons.add_circle, '/waste_input', false),
                  _buildNavItem(context, "Reports", Icons.bar_chart_outlined, Icons.bar_chart, '/reports', false),
                  _buildNavItem(context, "Restaurant Tracker", Icons.location_on_outlined, Icons.location_on, '/restaurant_tracker', false),
                  _buildNavItem(context, "Food Transfer", Icons.volunteer_activism_outlined, Icons.volunteer_activism, '/food_transfer', false),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Divider(color: _isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.12), thickness: 1),
                  ),
                  _buildNavItem(context, "Profile", Icons.person_outline, Icons.person, '/profile', false),
                  _buildNavItem(context, "Settings", Icons.settings_outlined, Icons.settings, '/settings', true),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor,
                      secondaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.zero,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.25),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                    },
                    borderRadius: BorderRadius.zero,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData iconOutlined, IconData iconFilled, String route, bool isSelected) {
    Color itemTextColor = _isDarkMode 
        ? (isSelected ? primaryColor : Colors.grey[300]!)
        : (isSelected ? primaryColor : Color(0xFF64748B));
        
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected 
                ? (_isDarkMode ? primaryColor.withOpacity(0.15) : primaryColor.withOpacity(0.08)) 
                : Colors.transparent,
            borderRadius: BorderRadius.zero,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? (_isDarkMode ? primaryColor.withOpacity(0.2) : primaryColor.withOpacity(0.12))
                        : (_isDarkMode ? Colors.grey.withOpacity(0.15) : Colors.grey.withOpacity(0.08)),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Icon(
                    isSelected ? iconFilled : iconOutlined,
                    color: isSelected ? primaryColor : (_isDarkMode ? Colors.grey[300] : Color(0xFF94A3B8)),
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: itemTextColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                if (isSelected) ...[
                  Spacer(),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, "Appearance"),
            SizedBox(height: 16),
            _buildSettingCard(
              child: SwitchListTile(
                title: Text(
                  AppLocalizations.of(context)?.translate("dark_mode") ?? "Dark Mode",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                subtitle: Text(
                  "Switch between light and dark theme",
                  style: TextStyle(
                    fontSize: 14,
                    color: subtitleColor,
                  ),
                ),
                value: _isDarkMode,
                onChanged: (bool value) {
                  setState(() {
                    _isDarkMode = value;
                    _updateThemeColors();
                  });
                  widget.onThemeChanged(value);
                },
                activeColor: primaryColor,
                activeTrackColor: primaryColor.withOpacity(0.5),
                inactiveThumbColor: Colors.grey[300],
                inactiveTrackColor: Colors.grey[400],
              ),
              leadingIcon: Icons.dark_mode,
            ),
            SizedBox(height: 24),
            _buildSectionTitle(context, "Language"),
            SizedBox(height: 16),
            _buildSettingCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16, top: 16, right: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _isDarkMode ? primaryColor.withOpacity(0.2) : primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Icon(
                            Icons.language,
                            color: primaryColor,
                            size: 22,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)?.translate("language") ?? "Language",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Select your preferred language",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: subtitleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Divider(color: _isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1), thickness: 1),
                  _buildLanguageOption(context, "English", "en"),
                  Divider(color: _isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1), thickness: 1),
                  _buildLanguageOption(context, "Gujarati", "gu"),
                  Divider(color: _isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1), thickness: 1),
                  _buildLanguageOption(context, "Hindi", "hi"),
                  SizedBox(height: 8),
                ],
              ),
              leadingIcon: null,
            ),
            SizedBox(height: 24),
            _buildSectionTitle(context, "About"),
            SizedBox(height: 16),
            _buildSettingCard(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isDarkMode ? primaryColor.withOpacity(0.2) : primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: primaryColor,
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Version",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Waste Management v1.0.0",
                            style: TextStyle(
                              fontSize: 14,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              leadingIcon: null,
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String language, String code) {
    bool isSelected = widget.selectedLanguage == code;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          widget.onLanguageChanged(code);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                language,
                style: TextStyle(
                  fontSize: 15,
                  color: isSelected 
                      ? primaryColor 
                      : (_isDarkMode ? Colors.grey[300] : Color(0xFF64748B)),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              if (isSelected)
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({required Widget child, IconData? leadingIcon}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 1,
            color: dividerColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.facebook, color: Colors.white, size: 28),
              SizedBox(width: 30),
              Icon(Icons.photo_camera, color: Colors.white, size: 28),
              SizedBox(width: 30),
              Icon(Icons.public, color: Colors.white, size: 28),
            ],
          ),
          SizedBox(height: 16),
          Text(
            "© 2025 Waste Management",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "All rights reserved",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
