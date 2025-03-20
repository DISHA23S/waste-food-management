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

  @override
  void initState() {
    super.initState();
    _fetchWasteData();
  }

  Future<void> _fetchWasteData() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    // Redirect if not logged in
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
    final querySnapshot = await FirebaseFirestore.instance
        .collection('waste_logs')
        .get();

    for (var doc in querySnapshot.docs) {
      final entries = doc.data()['entries'] as List<dynamic>?;

      if (entries != null) {
        for (var entry in entries) {
          final String restaurantName = (entry['restaurant'] ?? '').trim();
          final String currentUserRestaurant = (user.displayName ?? '').trim();

          print("Firebase restaurant: $restaurantName | Current user: $currentUserRestaurant");

          if (restaurantName.isNotEmpty && restaurantName == currentUserRestaurant) {
            final double wasteAmount = double.tryParse(entry['quantity'] ?? '0') ?? 0.0;
            final String status = entry['status'] ?? 'Pending';

            total += wasteAmount;
            if (status == 'Transferred') {
              transferred += wasteAmount;
            }
          }
        }
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
      appBar: AppBar(
        title: Text("Dashboard"),
        backgroundColor: AppColors.primary,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              child: Text("Waste Management", style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
            _buildNavItem(context, "Dashboard", Icons.dashboard, '/dashboard'),
            _buildNavItem(context, "Input Waste", Icons.add, '/waste_input'),
            _buildNavItem(context, "Reports", Icons.bar_chart, '/reports'),
            _buildNavItem(context, "Restaurant Tracker", Icons.location_on, '/restaurant_tracker'),
            _buildNavItem(context, "Food Transfer", Icons.volunteer_activism, '/food_transfer'),
            _buildNavItem(context, "Profile", Icons.person, '/profile'),
            _buildNavItem(context, "Settings", Icons.settings, '/settings'),
            _buildLogoutItem(context),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, Restaurant Owner!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoCard("Total Waste", "${totalWaste.toStringAsFixed(1)} kg", Icons.delete, Colors.red),
                _buildInfoCard("Food Transferred", "${foodTransferred.toStringAsFixed(1)} kg", Icons.restaurant, AppColors.secondary),
              ],
            ),
            SizedBox(height: 20),
            Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(context, "Input Waste", Icons.add, '/waste_input'),
                _buildActionButton(context, "Reports", Icons.bar_chart, '/reports'),
                _buildActionButton(context, "Tracker", Icons.location_on, '/restaurant_tracker'),
                _buildActionButton(context, "Food Transfer", Icons.volunteer_activism, '/food_transfer'),
                _buildActionButton(context, "Profile", Icons.person, '/profile'),
                _buildActionButton(context, "Settings", Icons.settings, '/settings'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Container(
        width: 160,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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

  Widget _buildActionButton(BuildContext context, String title, IconData icon, String route) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, route);
          },
          child: CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.accent,
            child: Icon(icon, size: 30, color: Colors.white),
          ),
        ),
        SizedBox(height: 5),
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.logout, color: Colors.red),
      title: Text("Logout", style: TextStyle(color: Colors.red)),
      onTap: () async {
        await FirebaseAuth.instance.signOut(); // Sign out user
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      },
    );
  }
}
