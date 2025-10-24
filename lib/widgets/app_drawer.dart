import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instruo_application/helper/helper_functions.dart';
import 'package:instruo_application/home_page.dart';
import 'package:instruo_application/screens/map_page.dart';
import 'package:instruo_application/screens/hackathon_page.dart';
import '../screens/timeline/timeline_page.dart';
import '../contact/contact_us.dart';
import '../theme/theme.dart';
import '../events/events_container.dart';
import '../screens/coordinator/coordinator_dashboard_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instruo_application/widgets/theme_toggle_button.dart';

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

  /// ✅ Fixed Navigation Logic
  void _onTapNavigate(
    BuildContext context,
    String routeName,
    WidgetBuilder builder, {
    bool resetStack = false,
  }) {
    // Close the drawer
    Navigator.pop(context);

    // Avoid pushing if already on that page
    final currentName = ModalRoute.of(context)?.settings.name;
    if (currentName == routeName) return;

    final route = MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: builder,
    );

    if (resetStack) {
      // For home — reset entire navigation stack
      Navigator.pushAndRemoveUntil(context, route, (Route<dynamic> r) => false);
    } else {
      // ✅ Use push instead of pushReplacement
      // Keeps back stack intact so pressing back goes to previous screen
      Navigator.push(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Larger header to accommodate a bigger GIF/logo
                Container(
                  height: 220, // increased height for larger GIF
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Use a larger image and preserve aspect ratio
                        Image.asset(
                          'assets/instruo-app-splashscreen.gif',
                          // width: 220,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "INSTRUO'14",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    children: [
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
                        icon: Icons.computer,
                        text: "Hackathon",
                        onTap: () => _onTapNavigate(
                          context,
                          '/sponsors',
                          (ctx) => Hackathon(),
                        ),
                      ),

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

                      // Info tile removed — theme toggle is available at the bottom of the drawer.
                    ],
                  ),
                )
              ],
            ),
          ),

          // Bottom centered toggle button
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  ThemeToggleButton(),
                  SizedBox(width: 12),
                  Text('Toggle Theme', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
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
