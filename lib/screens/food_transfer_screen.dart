import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';

class FoodTransferScreen extends StatefulWidget {
  @override
  _FoodTransferScreenState createState() => _FoodTransferScreenState();
}

class _FoodTransferScreenState extends State<FoodTransferScreen> with SingleTickerProviderStateMixin {
  String filterStatus = "All"; // Default filter
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Color primaryColor = Color(0xFF40B59F);
  final Color secondaryColor = Color(0xFF3AA391);
  
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
  }

  void _updateThemeColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    backgroundColor = isDark ? Color(0xFF121212) : Color(0xFFF7FAFC);
    cardColor = isDark ? Color(0xFF1E1E1E) : Colors.white;
    textColor = isDark ? Colors.white : Color(0xFF2D3748);
    subtitleColor = isDark ? Colors.grey[300]! : Color(0xFF64748B);
    iconBackgroundColor = isDark ? primaryColor.withOpacity(0.2) : primaryColor.withOpacity(0.1);
    dividerColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Update theme colors based on current brightness
    _updateThemeColors(context);
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      drawer: _buildDrawer(),
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
              // Large circle in top right
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
              // Medium circle in middle left
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
              // Small circle in bottom right
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
                      actions: [
                        IconButton(
                          icon: Icon(Icons.refresh, color: Colors.white, size: 26),
                          onPressed: () {
                            setState(() {});
                          },
                        ),
                        SizedBox(width: 8),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 50, right: 24, top: 80, bottom: 0),
                      child: Text(
                        "Food Transfer",
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
                    child: _buildTransferContent(),
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

  Widget _buildDrawer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1E1E1E) : Colors.white.withOpacity(0.95),
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
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    FirebaseAuth.instance.currentUser?.displayName ?? "User",
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
                  _buildNavItem("Dashboard", Icons.dashboard_outlined, Icons.dashboard, '/dashboard', false),
                  _buildNavItem("Input Waste", Icons.add_circle_outline, Icons.add_circle, '/waste_input', false),
                  _buildNavItem("Reports", Icons.bar_chart_outlined, Icons.bar_chart, '/reports', false),
                  _buildNavItem("Restaurant Tracker", Icons.location_on_outlined, Icons.location_on, '/restaurant_tracker', false),
                  _buildNavItem("Food Transfer", Icons.volunteer_activism_outlined, Icons.volunteer_activism, '/food_transfer', true),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Divider(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.12), thickness: 1),
                  ),
                  _buildNavItem("Profile", Icons.person_outline, Icons.person, '/profile', false),
                  _buildNavItem("Settings", Icons.settings_outlined, Icons.settings, '/settings', false),
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

  Widget _buildNavItem(String title, IconData iconOutlined, IconData iconFilled, String route, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color itemTextColor = isDark 
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
                ? (isDark ? primaryColor.withOpacity(0.15) : primaryColor.withOpacity(0.08)) 
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
                        ? (isDark ? primaryColor.withOpacity(0.2) : primaryColor.withOpacity(0.12))
                        : (isDark ? Colors.grey.withOpacity(0.15) : Colors.grey.withOpacity(0.08)),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Icon(
                    isSelected ? iconFilled : iconOutlined,
                    color: isSelected ? primaryColor : (isDark ? Colors.grey[300] : Color(0xFF94A3B8)),
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

  Widget _buildTransferContent() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 20),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Filter by Status",
                  labelStyle: TextStyle(
                    color: subtitleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
              ),
              value: filterStatus,
                icon: Icon(Icons.filter_list, color: primaryColor),
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              items: ["All", "Pending", "Transferred"].map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  filterStatus = value!;
                });
              },
            ),
          ),
            FutureBuilder(
              future: fetchCombinedData(),
              builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Container(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          "Error Loading Data",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "${snapshot.error}",
                          style: TextStyle(
                            fontSize: 16,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final combinedData = snapshot.data!.where((data) {
                  if (filterStatus == "All") return true;
                  return data['status'] == filterStatus;
                }).toList();

                if (combinedData.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(30),
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.search_off, size: 64, color: subtitleColor.withOpacity(0.5)),
                        SizedBox(height: 16),
                        Text(
                          "No Records Found",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "There are no food transfer records matching your filter",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: combinedData.map((data) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                          children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  data['status'] == 'Transferred' 
                                      ? primaryColor     
                                      : primaryColor,
                                  data['status'] == 'Transferred'
                                      ? secondaryColor   
                                      : secondaryColor,
                                ],
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                        ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                          children: [
                                    Icon(
                                      data['status'] == 'Transferred'
                                          ? Icons.check_circle
                                          : Icons.pending_actions,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                            Text(
                              data['status'] ?? "Unknown",
                              style: TextStyle(
                                        color: Colors.white,
                                fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  data['date'] ?? "No date",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.storefront, color: primaryColor),
                                    SizedBox(width: 8),
                                    Text(
                                      "${data['restaurant'] ?? 'Unknown Restaurant'}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(Icons.category, size: 20, color: subtitleColor),
                                          SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              "${data['waste_type'] ?? 'Unknown type'}",
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: subtitleColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(Icons.scale, size: 20, color: subtitleColor),
                                          SizedBox(width: 8),
                                          Text(
                                            "${data['quantity'] ?? '0'} kg",
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: subtitleColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 20, color: subtitleColor),
                                    SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        "${data['location'] ?? 'Unknown location'}",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: subtitleColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (data['status'] == 'Pending') ...[
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              primaryColor,
                                              secondaryColor,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: primaryColor.withOpacity(0.25),
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              // Need to implement transfer action
                                              _markAsTransferred(data);
                                            },
                                            borderRadius: BorderRadius.circular(8),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              child: Text(
                                                "Transfer Now",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    SizedBox(width: 12),
                                    TextButton.icon(
                                      icon: Icon(Icons.info_outline, color: primaryColor),
                                      label: Text(
                                        "Details",
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              onPressed: () => _showDetailsDialog(data),
                            ),
                          ],
                        ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
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
              Icon(Icons.email_outlined, color: Colors.white, size: 28),
              SizedBox(width: 30),
              Icon(Icons.phone_outlined, color: Colors.white, size: 28),
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

  Future<List<Map<String, dynamic>>> fetchCombinedData() async {
    try {
    final foodTransfers = await FirebaseFirestore.instance.collection('food_transfers').get();
    final wasteLogs = await FirebaseFirestore.instance.collection('waste_logs').get();

    List<Map<String, dynamic>> transfersData = foodTransfers.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['docId'] = doc.id; // Add document ID
        return data;
    }).toList();

      // Process waste_logs collection
    List<Map<String, dynamic>> wasteData = [];
    for (var doc in wasteLogs.docs) {
      var entries = doc.data()['entries'];
      if (entries != null && entries is List) {
          for (var i = 0; i < entries.length; i++) {
            var entry = Map<String, dynamic>.from(entries[i] as Map);
            entry['docId'] = doc.id; // Add document ID
            entry['entryIndex'] = i; // Add index in the entries array
            wasteData.add(entry);
        }
      }
    }

    return [...transfersData, ...wasteData];
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  void _markAsTransferred(Map<String, dynamic> data) async {
    try {
      final docId = data['docId'];
      final entryIndex = data['entryIndex'];
      
      if (docId == null) return;
      
      final docRef = FirebaseFirestore.instance.collection('waste_logs').doc(docId);
      
      if (entryIndex != null) {
        // This is a waste log entry
        final snapshot = await docRef.get();
        if (snapshot.exists) {
          List<dynamic> updatedEntries = List.from(snapshot['entries']);
          updatedEntries[entryIndex]['status'] = "Transferred";
          await docRef.update({'entries': updatedEntries});
          
          // Optional: Add a record to food_transfers collection
          await FirebaseFirestore.instance.collection('food_transfers').add({
            'restaurant': data['restaurant'],
            'waste_type': data['waste_type'],
            'quantity': data['quantity'],
            'location': data['location'],
            'date': data['date'],
            'status': 'Transferred',
            'transferred_at': FieldValue.serverTimestamp(),
            'source_doc': docId,
            'source_entry_index': entryIndex,
          });
          
          setState(() {}); // Refresh UI
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully marked as transferred!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error marking as transferred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showDetailsDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Transfer Details",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 20),
              ...data.entries
                  .where((e) => !['docId', 'entryIndex'].contains(e.key)) // Filter out internal keys
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${_formatKey(e.key)}: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: subtitleColor,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "${e.value}",
                                style: TextStyle(
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Close",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatKey(String key) {
    // Convert snake_case to Title Case
    return key.split('_').map((word) => 
      word.isNotEmpty 
        ? word[0].toUpperCase() + word.substring(1) 
        : ''
    ).join(' ');
  }
}
