import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}
  
class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  double totalWaste = 0.0;
  double foodTransferred = 0.0;
  String userName = "User";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Theme colors
  late Color backgroundColor;
  late Color cardColor;
  late Color textColor;
  late Color subtitleColor;
  late Color iconBackgroundColor;
  late Color dividerColor;

  @override
  void initState() {
    super.initState();
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
    _fetchWasteData();
    _fetchUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateThemeColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    backgroundColor = isDark ? Color(0xFF121212) : Color(0xFFF8F9FA);
    cardColor = isDark ? Color(0xFF1E1E1E) : Colors.white;
    textColor = isDark ? Colors.white : Color(0xFF2D3748);
    subtitleColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    iconBackgroundColor = isDark ? Color(0xFF40B59F).withOpacity(0.2) : Color(0xFF40B59F).withOpacity(0.1);
    dividerColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2);
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? user.email ?? "User";
      });
    }
  }

  Future<void> _fetchWasteData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final wasteQuery = await FirebaseFirestore.instance.collection('waste_logs').get();
      final transferQuery = await FirebaseFirestore.instance.collection('food_transfers').get();

    double total = 0.0;
    double transferred = 0.0;

      for (var doc in wasteQuery.docs) {
        final data = doc.data();
        if ((data['restaurant'] ?? '').trim() == user.displayName?.trim()) {
          total += double.tryParse(data['quantity']?.toString() ?? '0') ?? 0.0;
        }
      }

      for (var doc in transferQuery.docs) {
        final data = doc.data();
        if ((data['restaurant'] ?? '').trim() == user.displayName?.trim()) {
          transferred += double.tryParse(data['quantity']?.toString() ?? '0') ?? 0.0;
        }
      }

      if (mounted) {
        setState(() {
          totalWaste = total;
          foodTransferred = transferred;
        });
      }
    } catch (e) {
      print('Error fetching waste data: $e');
    }
  }

  void _navigateToAwarenessDetail(String title, String description, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AwarenessDetailScreen(
          title: title,
          description: description,
          imagePath: imagePath,
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.zero,
            ),
            child: Icon(
              icon,
              color: Color(0xFF40B59F),
              size: 24,
            ),
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAwarenessItem(String imagePath, String title, String desc) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToAwarenessDetail(title, desc, imagePath),
        borderRadius: BorderRadius.zero,
        child: Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.zero,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.zero,
                child: Image.asset(
                  imagePath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF40B59F),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: EdgeInsets.all(24),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Contact Us",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.zero,
                ),
                child: Icon(
                  Icons.mail_outline,
                  color: Color(0xFF40B59F),
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Email Us",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "sdisha3574@gmail.com",
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
          SizedBox(height: 16),
          Divider(color: dividerColor),
          SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.zero,
                ),
                child: Icon(
                  Icons.phone_outlined,
                  color: Color(0xFF40B59F),
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Call Us",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "0987654321",
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
        ],
      ),
    );
  }

  Widget _buildFooter() {
  return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
    decoration: BoxDecoration(
        color: Color(0xFF40B59F),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
    ),
    child: Column(
      children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.facebook, color: Colors.white, size: 24),
              SizedBox(width: 20),
              Icon(Icons.photo_camera, color: Colors.white, size: 24),
              SizedBox(width: 20),
              Icon(Icons.public, color: Colors.white, size: 24),
            ],
          ),
          SizedBox(height: 16),
          Text(
            "© 2025 Waste Management",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "All Rights Reserved",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
      ],
    ),
  );
}

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
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
                    Color(0xFF40B59F),
                    Color(0xFF3AA391),
                  ],
                ),
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
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: Color(0xFF40B59F),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    userName,
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
                  _buildNavItemEnhanced(
                    "Dashboard",
                    Icons.dashboard_outlined,
                    Icons.dashboard,
                    '/dashboard',
                    true,
                  ),
                  _buildNavItemEnhanced(
                    "Input Waste",
                    Icons.add_circle_outline,
                    Icons.add_circle,
                    '/waste_input',
                    false,
                  ),
                  _buildNavItemEnhanced(
                    "Reports",
                    Icons.bar_chart_outlined,
                    Icons.bar_chart,
                    '/reports',
                    false,
                  ),
                  _buildNavItemEnhanced(
                    "Restaurant Tracker",
                    Icons.location_on_outlined,
                    Icons.location_on,
                    '/restaurant_tracker',
                    false,
                  ),
                  _buildNavItemEnhanced(
                    "Food Transfer",
                    Icons.volunteer_activism_outlined,
                    Icons.volunteer_activism,
                    '/food_transfer',
                    false,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Divider(color: Colors.grey.withOpacity(0.12), thickness: 1),
                  ),
                  _buildNavItemEnhanced(
                    "Profile",
                    Icons.person_outline,
                    Icons.person,
                    '/profile',
                    false,
                  ),
                  _buildNavItemEnhanced(
                    "Settings",
                    Icons.settings_outlined,
                    Icons.settings,
                    '/settings',
                    false,
                  ),
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
                      Color(0xFF40B59F),
                      Color(0xFF3AA391),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF40B59F).withOpacity(0.25),
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
                    borderRadius: BorderRadius.circular(12),
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

  Widget _buildNavItemEnhanced(String title, IconData iconOutlined, IconData iconFilled, String route, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF40B59F).withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFF40B59F).withOpacity(0.12) : Colors.grey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isSelected ? iconFilled : iconOutlined,
                    color: isSelected ? Color(0xFF40B59F) : Color(0xFF94A3B8),
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? Color(0xFF40B59F) : Color(0xFF64748B),
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
                      color: Color(0xFF40B59F),
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
  @override
  Widget build(BuildContext context) {
    // Update theme colors based on current brightness
    _updateThemeColors(context);
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: Color(0xFF40B59F),
                leading: IconButton(
                  icon: Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color(0xFF40B59F),
                          Color(0xFF3AA391),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -50,
                          top: -50,
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
                          left: -30,
                          bottom: -30,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
    children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Waste',
                            '3 kg',
                            Icons.delete_outline,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Food Transferred',
                            '4 kg',
                            Icons.restaurant,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    Text(
                      'No Food Waste Awareness',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildAwarenessItem(
                      "assets/plan_meals.png",
                      "Plan Your Meals",
                      "Learn how to effectively plan your meals to reduce food waste",
                    ),
                    _buildAwarenessItem(
                      "assets/donate_food.png",
                      "Donate Excess Food",
                      "Find out how to donate your excess food to those in need",
                    ),
                    _buildAwarenessItem(
                      "assets/use_leftovers.png",
                      "Use Leftovers",
                      "Creative ways to use and store leftover food",
                    ),
                    _buildAwarenessItem(
                      "assets/compost.png",
                      "Compost Waste",
                      "Learn about composting and its environmental benefits",
                    ),
                    SizedBox(height: 32),
                    _buildContactSection(),
                    _buildFooter(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AwarenessDetailScreen extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const AwarenessDetailScreen({
    Key? key,
    required this.title,
    required this.description,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7FAFC),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Color(0xFF40B59F),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              imagePath,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.6,
                    ),
                  ),
                  // Add more detailed content here
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}