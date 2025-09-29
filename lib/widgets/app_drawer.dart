import 'package:flutter/material.dart';
import 'package:instruo_application/events/gaming_page.dart';
import 'package:instruo_application/events/general_page.dart';
import 'package:instruo_application/events/robotics_page.dart';
import 'package:instruo_application/events/technical_page.dart';
import 'package:instruo_application/home_page.dart';
import 'package:instruo_application/screens/sponsor_page.dart';
import '../contact/contact_us.dart';
import '../theme/theme.dart';

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
            icon: Icons.code,
            text: "Technical",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TechnicalPage()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.music_note,
            text: "General",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GeneralPage()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.smart_toy,
            text: "Robotics",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RoboticsPage()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.sports_esports,
            text: "Gaming",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GamingPage()),
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
