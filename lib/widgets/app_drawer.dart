import 'package:flutter/material.dart';
import 'package:instruo_application/events/gaming_page.dart';
import 'package:instruo_application/events/general_page.dart';
import 'package:instruo_application/events/robotics_page.dart';
import 'package:instruo_application/events/technical_page.dart';
import 'package:instruo_application/home_page.dart';
import 'package:instruo_application/screens/sponsor_page.dart';
import '../contact/contact_us.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage("assets/fest_logo.png"),
                ),
                SizedBox(height: 10),
                Text("INSTRUO'14",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.code),
            title: Text("Technical"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TechnicalPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.music_note),
            title: Text("General"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GeneralPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.sports),
            title: Text("Robotics"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RoboticsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.work),
            title: Text("Gaming"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GamingPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.work),
            title: Text("Sponsors"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SponsorsPage()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.contact_mail),
            title: Text("Contact Us"),
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
}
