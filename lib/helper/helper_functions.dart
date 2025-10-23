import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/auth.dart';
import '../screens/profile_page.dart';

// helper_functions.dart
// lib/helper/helper_functions.dart
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> launchDialer(String input, BuildContext context, {bool isUrl = false}) async {
  if (isUrl) {
    // Open as URL
    final Uri uri = Uri.parse(input);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open the link.")),
      );
    }
    return;
  }

  // Open as phone number
  final status = await Permission.phone.request();
  if (status.isGranted) {
    final Uri uri = Uri.parse("tel:$input");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not launch dialer.")),
      );
    }
  } else if (status.isDenied) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Phone permission denied.")),
    );
  } else if (status.isPermanentlyDenied) {
    openAppSettings();
  }
}



// Function to display a message to the user
void displayMessageToUser(String message, BuildContext context, {bool isError = true, int durationSeconds = 2}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : null,
      duration: Duration(seconds: durationSeconds),
    ),
  );
}

// Authentication helper functions for AppBar
class AppBarAuthHelper {
  static void handleMenuAction(String value, BuildContext context, 
      {VoidCallback? onStateChange}) async {
    switch (value) {
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        break;
      case 'logout':
        _handleLogout(context, onStateChange);
        break;
      case 'login':
        _navigateToLogin(context, onStateChange);
        break;
    }
  }

  static void _handleLogout(BuildContext context, VoidCallback? onStateChange) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              try {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  displayMessageToUser('Successfully logged out', context, isError: false);
                  onStateChange?.call(); // Notify parent to refresh state
                }
              } catch (e) {
                if (context.mounted) {
                  displayMessageToUser('Error logging out: $e', context);
                }
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  static void _navigateToLogin(BuildContext context, VoidCallback? onStateChange) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
    ).then((_) {
      // Refresh user state when returning from login
      onStateChange?.call();
    });
  }

  static List<PopupMenuEntry<String>> buildMenuItems(User? currentUser, Map<String, dynamic>? userData) {
    if (currentUser != null) {
      // User is logged in - show profile and logout
      return [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person, size: 20),
              const SizedBox(width: 8),
              const Text('Profile'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
        ),
      ];
    } else {
      // User is not logged in - show login option
      return [
        const PopupMenuItem(
          value: 'login',
          child: Row(
            children: [
              Icon(Icons.login, size: 20),
              SizedBox(width: 8),
              Text('Login'),
            ],
          ),
        ),
      ];
    }
  }

  static Future<Map<String, dynamic>?> loadUserData(User? currentUser) async {
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.email)
            .get();
        
        if (userDoc.exists) {
          return userDoc.data() as Map<String, dynamic>?;
        }
      } catch (e) {
        print('Error loading user data: $e');
        
        // Check if it's a Firestore database not found error
        if (e.toString().contains('database (default) does not exist')) {
          print('Firestore database not set up. Profile will show basic info only.');
          // Return basic user data from Firebase Auth
          return {
            'username': currentUser.email!.split('@')[0],
            'email': currentUser.email,
            'uid': currentUser.uid,
            'createdAt': 'Database not configured'
          };
        }
      }
    }
    return null;
  }
}
