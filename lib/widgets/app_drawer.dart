import 'package:flutter/material.dart';
import 'package:instruo_application/home_page.dart';
import 'package:instruo_application/screens/sponsor_page.dart';
import 'package:instruo_application/screens/workshop_page.dart';
import '../contact/contact_us.dart';
import '../theme/theme.dart';
import '../events/events_container.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundImage: const AssetImage("assets/fest_logo.png"),
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(height: 12),
                Text(
                  "INSTRUO'14",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),

          _buildDrawerItem(
            context,
            icon: Icons.home,
            text: "Home",
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.event,
            text: "Events",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventsContainer(initialIndex: 0)),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.work,
            text: "Workshops",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WorkshopsPage()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.star,
            text: "Sponsors",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SponsorsPage()),
              );
            },
          ),

          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.contact_mail,
            text: "Contact Us",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContactUsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon,
      required String text,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryPurple),
      title: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      onTap: onTap,
    );
  }
}
