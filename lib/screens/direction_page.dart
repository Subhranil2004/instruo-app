import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/theme.dart'; // your theme file
import '../widgets/app_drawer.dart';
import '../widgets/custom_app_bar.dart';

class DirectionsPage extends StatelessWidget {
  const DirectionsPage({super.key});

  Future<void> _openMap(double lat, double lng) async {
  final Uri googleMapUrl = Uri.parse(
    "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=walking",
  );

  // Always use external application mode for maps
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

    return Scaffold(
       appBar:  CustomAppBar(
        title: "CAMPUS DIRECTION",
        showBackButton: false,
        showProfileButton: false,
      ),
      drawer: AppDrawer(), // your app drawer
      backgroundColor: theme.colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "Select a Location",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildLocationButton(context, "First Gate", 22.557458, 88.306860),
            _buildLocationButton(context, "Main Academic Building", 22.555267081275407, 88.3078943430084),
            _buildLocationButton(context, "Ramanujan Central Library", 22.555079004722263, 88.30903870241728),
            _buildLocationButton(context, "Netaji Bhawan", 22.555952, 88.307640),
            _buildLocationButton(context, "Registration Desk", 22.55594452231021, 88.30817220046201),
            _buildLocationButton(context, "Lords", 22.55594452231021, 88.30817220046201),
            _buildLocationButton(context, "Institute Hall", 22.555509, 88.306651),
            _buildLocationButton(context, "S & T Building", 22.554009, 88.306425),
            _buildLocationButton(context, "Hospital", 22.557001, 88.305366),
            _buildLocationButton(context, "Alumni Seminar Hall", 22.554009, 88.306425),
            _buildLocationButton(context, "Sengupta Hall", 22.555900264546455, 88.31015481809995),
            _buildLocationButton(context, "Sen Hall", 22.556045171036878, 88.30938234193817),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationButton(
      BuildContext context, String name, double lat, double lng) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        onPressed: () => _openMap(lat, lng),
        child: Text(
          "$name",
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
