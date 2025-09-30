// lib/contact_us_page.dart
import 'package:flutter/material.dart';
import 'package:instruo_application/widgets/custom_app_bar.dart';
import 'contact_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  Future<void> _launchDialer(String phoneNumber) async {
  final status = await Permission.phone.request();
  debugPrint("Permission Status: $status");

  if (status.isGranted) {
    // Permission granted, proceed
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
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 20.0, bottom: 10.0),
        child: ListView.builder(
          itemCount: coreTeamContacts.length,
          itemBuilder: (context, index) {
            final contact = coreTeamContacts[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(contact.name, style: Theme.of(context).textTheme.titleMedium),
                subtitle: Text(contact.role, style: Theme.of(context).textTheme.bodySmall),
                trailing: IconButton(
                  icon: const Icon(Icons.phone, color: Colors.green),
                  onPressed: () => _launchDialer(contact.phone),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}