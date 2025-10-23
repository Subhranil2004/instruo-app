import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instruo_application/home_page.dart';
import 'package:instruo_application/screens/map_page.dart';
import 'package:instruo_application/screens/sponsor_page.dart';
import '../screens/timeline/timeline_page.dart';
import '../contact/contact_us.dart';
import '../theme/theme.dart';
import '../events/events_container.dart';
import '../screens/coordinator/coordinator_dashboard_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _isCoordinator = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkCoordinatorStatus();
  }

  Future<void> _checkCoordinatorStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.email)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          final isCoordinator = userData?['isCoordinator'] ?? false;
          setState(() {
            _isCoordinator = isCoordinator;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
  void _onTapNavigate(
    /*
    Closes the drawer
    Checks the current route name to prevent duplicate pushes
    Builds a route with RouteSettings(name: routeName)
    Navigates using:
      pushAndRemoveUntil when resetStack is true (Home)
      pushReplacement otherwise (Events, Workshops, Sponsors, Contact)
    */
    BuildContext context,
    String routeName,
    WidgetBuilder builder, {
    bool resetStack = false,
  }) {
    // Close the drawer first
    Navigator.pop(context);

    // Avoid pushing if we're already on the destination
    final currentName = ModalRoute.of(context)?.settings.name;
    if (currentName == routeName) return;

    final route = MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: builder,
    );

    if (resetStack) {
      Navigator.pushAndRemoveUntil(context, route, (Route<dynamic> r) => false);
    } else {
      Navigator.pushReplacement(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // shape: const RoundedRectangleBorder(
      //   borderRadius: BorderRadius.only(
      //     topRight: Radius.circular(20),
      //     bottomRight: Radius.circular(20),
      //   ),
      // ),
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
                // CircleAvatar(
                //   radius: 36,
                //   backgroundImage: const AssetImage("assets/fest_logo.png"),
                //   backgroundColor: Colors.transparent,
                // ),
                // Image.asset("assets/instruo-gif.gif", height: 80),
                SvgPicture.asset(
                  'assets/instruo-gif.min.svg',
                  width: 100, // Optional: specify width
                  height: 100, // Optional: specify height
                  // fit: BoxFit.contain, // Optional: how the SVG should fit
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn), // Optional: apply a color filter
                ),
                // Image.asset("assets/instruo-app-splashscreen.gif", height: 100),
                // const SizedBox(height: 12),
                Text(
                  "INSTRUO'14",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        // fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),

          _buildDrawerItem(
            context,
            icon: Icons.home,
            text: "Home",
            onTap: () => _onTapNavigate(
              context,
              '/home',
              (ctx) => HomePage(),
              resetStack: true,
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.event,
            text: "Events",
            onTap: () => _onTapNavigate(
              context,
              '/events',
              (ctx) => const EventsContainer(initialIndex: 0),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.work,
            text: "Timeline",
            onTap: () => _onTapNavigate(
              context,
              '/timeline/day1',
              (ctx) => const TimelinePage(),
            ),
          ),

          _buildDrawerItem(
            context,
            icon: Icons.directions,
            text: "Campus Map",
            onTap: () => _onTapNavigate(
              context,
              '/direction',
              (ctx) => DirectionsPage(),
            ),
          ),
          
          _buildDrawerItem(
            context,
            icon: Icons.star,
            text: "Sponsors",
            onTap: () => _onTapNavigate(
              context,
              '/sponsors',
              (ctx) => SponsorsPage(),
            ),
          ),

          // Coordinator Section (only visible to coordinators)
          if (_isCoordinator && !_isLoading) ...[
            const Divider(),
            _buildDrawerItem(
              context,
              icon: Icons.manage_accounts,
              text: "Coordinator Dashboard",
              onTap: () => _onTapNavigate(
                context,
                '/coordinator/events',
                (ctx) => const CoordinatorDashboardPage(),
              ),
            ),
          ],

          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.contact_mail,
            text: "Contact Us",
            onTap: () => _onTapNavigate(
              context,
              '/contact',
              (ctx) => ContactUsPage(),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: ListTile(
              leading: Icon(Icons.info_outline, color: AppTheme.primaryBlue),
              // title: Text(
              //   'Theme',
              //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              // ),
              subtitle: const Text(
                'This app follows your device theme.',
              ),
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Theme'),
                    content: const Text('This app follows your device theme. To switch between light and dark mode, change your device appearance in Settings.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('OK')),
                    ],
                  ),
                );
              },
            ),
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
      leading: Icon(icon, color: AppTheme.primaryBlue),
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
