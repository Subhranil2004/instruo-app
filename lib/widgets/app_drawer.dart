import 'package:flutter/material.dart';

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
                Text("College Fest 2025",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.code),
            title: Text("Technical"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.music_note),
            title: Text("Cultural"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.sports),
            title: Text("Sports"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.work),
            title: Text("Workshops"),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.contact_mail),
            title: Text("Contact Us"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
