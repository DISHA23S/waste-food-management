import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double totalWaste = 0.0;
  double foodTransferred = 0.0;
  String userName = "User";

  @override
  void initState() {
    super.initState();
    _fetchWasteData();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? "User";
      });
    }
  }

  Future<void> _fetchWasteData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
      return;
    }

    double total = 0.0;
    double transferred = 0.0;

    try {
      final wasteQuery =
          await FirebaseFirestore.instance.collection('waste_logs').get();
      for (var doc in wasteQuery.docs) {
        final data = doc.data();
        if ((data['restaurant'] ?? '').trim() == user.displayName?.trim()) {
          total += double.tryParse(data['quantity']?.toString() ?? '0') ?? 0.0;
        }
      }

      final transferQuery =
          await FirebaseFirestore.instance.collection('food_transfers').get();
      for (var doc in transferQuery.docs) {
        final data = doc.data();
        if ((data['restaurant'] ?? '').trim() == user.displayName?.trim()) {
          transferred +=
              double.tryParse(data['quantity']?.toString() ?? '0') ?? 0.0;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Dashboard", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.header,
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Welcome, $userName!"),

              // Adjusted Card Sizes
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    // Small Total Waste Card (left-aligned)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        height: 160,
                        width: double.infinity,
                        child: _buildInfoCard(
                          "Total Waste",
                          "${totalWaste.toStringAsFixed(1)} kg",
                          Icons.delete,
                          Colors.red,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Large Food Transferred Card (Full width)
                    Container(
                      width: double.infinity,
                      height: 160,
                      child: _buildInfoCard(
                        "Food Transferred",
                        "${foodTransferred.toStringAsFixed(1)} kg",
                        Icons.restaurant,
                        AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              _buildSectionTitle("🍽 No Food Waste Awareness"),
              _buildScrollableAwareness(),

              SizedBox(height: 20),

              _buildSectionTitle("📞 Contact Us"),
              _buildContactSection(),

              SizedBox(height: 20),

              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildScrollableAwareness() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildAwarenessItem("assets/plan_meals.png", "Plan Your Meals", "Only buy what you need."),
        _buildAwarenessItem("assets/donate_food.png", "Donate Excess Food", "Share extra food."),
        _buildAwarenessItem("assets/use_leftovers.png", "Use Leftovers", "Store and reuse."),
        _buildAwarenessItem("assets/compost.png", "Compost Waste", "Turn waste into compost."),
      ],
    );
  }
Widget _buildAwarenessItem(String imagePath, String title, String desc) {
  return Container(
    width: double.infinity,
    height: 200,
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
    ),
    child: Column(
      children: [
        Image.asset(imagePath, width: 100, height: 100),
        SizedBox(height: 10),
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Text(desc, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    ),
  );
}

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.header),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.account_circle, size: 50, color: Colors.white),
                SizedBox(height: 8),
                Text("Welcome, $userName",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ],
            ),
          ),
          _buildNavItem("Dashboard", Icons.dashboard, '/dashboard'),
          _buildNavItem("Input Waste", Icons.add, '/waste_input'),
          _buildNavItem("Reports", Icons.bar_chart, '/reports'),
          _buildNavItem("Restaurant Tracker", Icons.location_on, '/restaurant_tracker'),
          _buildNavItem("Food Transfer", Icons.volunteer_activism, '/food_transfer'),
          _buildNavItem("Profile", Icons.person, '/profile'),
          _buildNavItem("Settings", Icons.settings, '/settings'),
          _buildLogoutItem(),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }

  Widget _buildLogoutItem() {
    return ListTile(
      leading: Icon(Icons.logout, color: Colors.red),
      title: Text("Logout", style: TextStyle(color: Colors.red)),
      onTap: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      },
    );
  }

  Widget _buildContactSection() {
  return Column(
    children: [
      ListTile(
        leading: Icon(Icons.email, color: AppColors.primary),
        title: Text(
          "Email: sdisha3574@gmail.com",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500), // Increased font size
        ),
      ),
      ListTile(
        leading: Icon(Icons.phone, color: AppColors.primary),
        title: Text(
          "Phone: 0987654321",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500), // Increased font size
        ),
      ),
    ],
  );
}


  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(10),
      color: AppColors.footer,
      child: Center(
          child: Text("© 2025 Waste Management | All Rights Reserved",
              style: TextStyle(color: Colors.white))),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
