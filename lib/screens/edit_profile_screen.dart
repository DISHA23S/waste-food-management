import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;
  bool _isChangingPassword = false; // Toggle for password fields

  @override
  void initState() {
    super.initState();
    nameController.text = user?.displayName ?? "";
    emailController.text = user?.email ?? "";
  }

  Future<void> _updateProfile() async {
    try {
      if (nameController.text.isNotEmpty) {
        await user?.updateDisplayName(nameController.text);
      }
      if (emailController.text.isNotEmpty && emailController.text != user?.email) {
        await user?.updateEmail(emailController.text);
      }
      await user?.reload();
      user = FirebaseAuth.instance.currentUser;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Future<void> _changePassword() async {
    if (newPasswordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter all password fields")),
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("New passwords do not match!")),
      );
      return;
    }

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: oldPasswordController.text,
      );

      await user!.reauthenticateWithCredential(credential);
      await user!.updatePassword(newPasswordController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password updated successfully!")),
      );

      setState(() {
        _isChangingPassword = false; // Hide password fields after success
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Full Name"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
              ),
              SizedBox(height: 20),

              // Change Password Section
              TextButton(
                onPressed: () {
                  setState(() {
                    _isChangingPassword = !_isChangingPassword;
                  });
                },
                child: Text(
                  _isChangingPassword ? "Cancel" : "Edit Password",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),

              // Password Fields
              if (_isChangingPassword) ...[
                TextField(
                  controller: oldPasswordController,
                  decoration: InputDecoration(labelText: "Old Password"),
                  obscureText: true,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: newPasswordController,
                  decoration: InputDecoration(labelText: "New Password"),
                  obscureText: true,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(labelText: "Confirm Password"),
                  obscureText: true,
                ),
                SizedBox(height: 20),

                // Save Password Button (Only shown when editing password)
                Center(
                  child: ElevatedButton(
                    onPressed: _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Button color
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("Save Password", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],

              // Save Profile & Cancel Buttons (Only shown when not editing password)
              if (!_isChangingPassword) ...[
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Cancel and return to the previous screen
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Button color
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text("Save Changes", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
