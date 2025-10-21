// lib/contact_us_page.dart
import 'package:flutter/material.dart';
import 'package:instruo_application/widgets/custom_app_bar.dart';
import 'contact_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/app_drawer.dart';
import '../theme/theme.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  Future<void> _launchDialer(String phoneNumber) async {
    final status = await Permission.phone.request();
    debugPrint("Permission Status: $status");

    if (status.isGranted) {
      final Uri uri = Uri.parse("tel:$phoneNumber");
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        debugPrint("Could not find a dialer app for: $phoneNumber");
        throw 'Could not launch $phoneNumber';
      }
    } else if (status.isDenied) {
      debugPrint("Permission was denied by the user.");
    } else if (status.isPermanentlyDenied) {
      debugPrint("Permission is permanently denied. Opening settings.");
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "CONTACT US",
        showBackButton: false,
        showProfileButton: false,
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: ListView.builder(
          itemCount: coreTeamContacts.length,
          itemBuilder: (context, index) {
            final contact = coreTeamContacts[index];
            final String name = contact.name;
            final String role = contact.role;
            final String phone = contact.phone;
            final String initial = name.isNotEmpty ? name[0].toUpperCase() : "?";

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  // Avatar with initial
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    radius: 24,
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Name and Role
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          role,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Call button
                  IconButton(
                    icon: const Icon(Icons.phone, color: Colors.green),
                    tooltip: "Call $name",
                    onPressed: () => _launchDialer(phone),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
