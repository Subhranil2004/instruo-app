// lib/contact_us_page.dart
import 'package:flutter/material.dart';
import 'package:instruo_application/widgets/custom_app_bar.dart';
import 'contact_info.dart';
import '../widgets/app_drawer.dart';
import '../theme/theme.dart';
import '../helper/helper_functions.dart'; // <- imported helper
class ContactUsPage extends StatelessWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  // Define the order of sections
  final List<String> sectionOrder = const [
    "Main Coordinator",
    "Joint Coordinator",
    "App Development",
    "Web Development",
    "Finance",
    "Sponsorship",
    "Event",
    "Robodarshan",
    "Design and Content",
    "Publicity",
    "Travel and Logistics",
    "Volunteer",
  ];

  @override
  Widget build(BuildContext context) {
    // Group contacts by section
    final Map<String, List<ContactInfo>> groupedContacts = {};
    for (var contact in coreTeamContacts) {
      if (!groupedContacts.containsKey(contact.section)) {
        groupedContacts[contact.section] = [];
      }
      groupedContacts[contact.section]!.add(contact);
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: "CONTACT US",
        showBackButton: false,
        showProfileButton: false,
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: ListView(
          children: [
            for (var section in sectionOrder)
              if (groupedContacts.containsKey(section)) ...[
                // Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    section.toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),

                // List of contacts under this section
                for (var contact in groupedContacts[section]!) 
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                          radius: 24,
                          child: Text(
                            contact.name.isNotEmpty
                                ? contact.name[0].toUpperCase()
                                : "?",
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                contact.role,
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.phone, color: Colors.green),
                          tooltip: "Call ${contact.name}",
                          onPressed: () =>
                              launchDialer(contact.phone, context),
                        ),
                      ],
                    ),
                  ),
              ],
          ],
        ),
      ),
    );
  }
}
