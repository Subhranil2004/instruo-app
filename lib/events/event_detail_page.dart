import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'events_model.dart';
import "../theme/theme.dart";
import "../widgets/app_drawer.dart";
import "../widgets/custom_app_bar.dart";
import 'event_register_page.dart';
import 'event_edit_page.dart';

class EventDetailPage extends StatefulWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isRegistered = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  Future<void> _checkRegistrationStatus() async {
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Check if user is already registered for this event
      final teamsQuery = await FirebaseFirestore.instance
          .collection('Teams')
          .where('eventId', isEqualTo: widget.event.id)
          .where('members', arrayContains: currentUser!.email!)
          .get();

      setState(() {
        _isRegistered = teamsQuery.docs.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Details, Rules, Coordinators
      child: Scaffold(
        // ✅ Top AppBar
        appBar: CustomAppBar(
          title: widget.event.name,
        ),

        // ✅ Left drawer (sidebar)
        drawer: AppDrawer(),

        // ✅ Floating circular register button with label
        floatingActionButton: _isLoading
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      elevation: 6,
                      shape: const CircleBorder(),
                      color: Colors.transparent,
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          color: _isRegistered 
                              ? AppTheme.secondaryPurple 
                              : Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: FloatingActionButton(
                          onPressed: () {
                            if (_isRegistered) {
                              // Navigate to edit page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventEditPage(event: widget.event),
                                ),
                              ).then((_) {
                                // Refresh registration status when returning
                                _checkRegistrationStatus();
                              });
                            } else {
                              // Navigate to register page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventRegisterPage(event: widget.event),
                                ),
                              ).then((_) {
                                // Refresh registration status when returning
                                _checkRegistrationStatus();
                              });
                            }
                          },
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          child: Icon(
                            _isRegistered ? Icons.edit : Icons.person_add,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isRegistered ? "Edit Details" : "Register",
                      style: Theme.of(context).popupMenuTheme.textStyle,
                    ),
                  ],
                ),
              ),

        body: Column(
          children: [
            // Top image (fixed 40% of screen)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              width: double.infinity,
              child: Image.asset(
                widget.event.image,
                fit: BoxFit.cover,
              ),
            ),

            // Tab bar directly below image

            Container(
              color: Theme.of(context).colorScheme.surface, // background of tab bar
              child: TabBar(
                indicatorColor: AppTheme.primaryBlue,      // underline for selected tab
                labelColor: AppTheme.primaryBlue,          // selected tab text color
                unselectedLabelColor: Theme.of(context).popupMenuTheme.textStyle?.color, // unselected tab text color
                tabs: const [
                  Tab(text: "Details"),
                  Tab(text: "Rules"),
                  Tab(text: "Coordinators"),
                ],
              ),
            ),


            // TabBarView content
            Expanded(
              child: TabBarView(
                children: [
                  // Details tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(widget.event.description),
                  ),

                  // Rules tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(widget.event.category),
                  ),

                  // Coordinators tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(widget.event.category),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
