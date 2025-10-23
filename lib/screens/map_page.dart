import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/custom_app_bar.dart';

class DirectionsPage extends StatelessWidget {
  const DirectionsPage({super.key});

  Future<void> _openMap(double lat, double lng) async {
    final Uri googleMapUrl = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=walking",
    );

    final bool launched = await launchUrl(
      googleMapUrl,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      throw 'Could not open the map.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> locations = [
      {"name": "First Gate", "lat": 22.557458, "lng": 88.306860},
      {"name": "Main Academic Building", "lat": 22.555267081275407, "lng": 88.3078943430084},
      {"name": "Ramanujan Central Library", "lat": 22.555079004722263, "lng": 88.30903870241728},
      {"name": "Netaji Bhawan", "lat": 22.555952, "lng": 88.307640},
      {"name": "Registration Desk", "lat": 22.55594452231021, "lng": 88.30817220046201},
      {"name": "Lords", "lat": 22.55594452231021, "lng": 88.30817220046201},
      {"name": "Institute Hall", "lat": 22.555509, "lng": 88.306651},
      {"name": "S & T Building", "lat": 22.554009, "lng": 88.306425},
      {"name": "Hospital", "lat": 22.557001, "lng": 88.305366},
      {"name": "Alumni Seminar Hall", "lat": 22.554009, "lng": 88.306425},
      {"name": "Sengupta Hall", "lat": 22.555900264546455, "lng": 88.31015481809995},
      {"name": "Sen Hall", "lat": 22.556045171036878, "lng": 88.30938234193817},
    ];

    return Scaffold(
      appBar: const CustomAppBar(
        title: "CAMPUS MAP",
        showBackButton: false,
        showProfileButton: false,
      ),
      drawer: const AppDrawer(),
      backgroundColor: theme.colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: locations.length,
          itemBuilder: (context, index) {
            final loc = locations[index];
            return _buildLocationTile(
              context,
              loc["name"],
              loc["lat"],
              loc["lng"],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLocationTile(
      BuildContext context, String name, double lat, double lng) {
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : "?";

    return GestureDetector(
      onTap: () => _openMap(lat, lng), // Directly call the original map logic
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
              child: Text(
                initial,
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: AppTheme.primaryBlue, size: 18),
          ],
        ),
      ),
    );
  }
}
