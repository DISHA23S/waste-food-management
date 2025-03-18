import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in, if not redirect to the login screen
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }

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
            // Waste Summary Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoCard("Total Waste", "120 kg", Icons.delete, Colors.red),
                _buildInfoCard("Food Transferred", "50 kg", Icons.restaurant, AppColors.secondary),
              ],
            ),
            SizedBox(height: 20),
            // Quick Actions
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
