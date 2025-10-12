import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/custom_app_bar.dart';
import '../../theme/theme.dart';
import '../../events/events_model.dart';
import '../../helper/helper_functions.dart';
import 'event_participants_page.dart';

class CoordinatorDashboardPage extends StatefulWidget {
  const CoordinatorDashboardPage({super.key});

  @override
  State<CoordinatorDashboardPage> createState() => _CoordinatorDashboardPageState();
}

class _CoordinatorDashboardPageState extends State<CoordinatorDashboardPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  List<Event> _coordinatingEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkCoordinatorStatus();
  }

  Future<void> _checkCoordinatorStatus() async {
    if (currentUser == null) {
      displayMessageToUser("Please login first", context);
      Navigator.pop(context);
      return;
    }

    try {
      // Check if user is a coordinator
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser!.email)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        final isCoordinator = userData?['isCoordinator'] ?? false;
        
        if (!isCoordinator) {
          displayMessageToUser("Access denied. Coordinator privileges required.", context);
          Navigator.pop(context);
          return;
        }

        setState(() {
          // User is confirmed as coordinator, proceed to load events
        });

        await _loadCoordinatedEvents();
      } else {
        displayMessageToUser("User data not found", context);
        Navigator.pop(context);
      }
    } catch (e) {
      displayMessageToUser("Error checking coordinator status: $e", context);
      Navigator.pop(context);
    }
  }

  Future<void> _loadCoordinatedEvents() async {
    try {
      // Load the current user's coordinating event IDs from Users collection
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser!.email)
          .get();

      if (!userDoc.exists) {
        setState(() {
          _coordinatingEvents = [];
          _isLoading = false;
        });
        return;
      }

      final userData = userDoc.data();
      final List<dynamic> coordIdsDynamic = userData?['coordinatingEvents'] ?? [];
      final List<String> coordIds = coordIdsDynamic.map((e) => e.toString()).toList();

      if (coordIds.isEmpty) {
        setState(() {
          _coordinatingEvents = [];
          _isLoading = false;
        });
        return;
      }

      // Firestore whereIn accepts max 10 items — split into chunks if needed
      final List<Event> events = [];
      const int chunkSize = 10;
      for (var i = 0; i < coordIds.length; i += chunkSize) {
        final end = (i + chunkSize < coordIds.length) ? i + chunkSize : coordIds.length;
        final chunk = coordIds.sublist(i, end);

        final q = await FirebaseFirestore.instance
            .collection('Events')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        
        for (final doc in q.docs) {
          final data = doc.data();
          events.add(Event.fromMap({
            'id': doc.id,
            ...data,
          }));
        }
      }

      // Keep original order as per coordIds (optional)
      final Map<String, Event> byId = {for (var e in events) e.id: e};
      final List<Event> ordered = coordIds.where((id) => byId.containsKey(id)).map((id) => byId[id]!).toList();
      print("ORDERED EVENTS IDS: ${ordered.map((e) => e.id).toList()}");
      print("ORDERED EVENTS NAMES: ${ordered.map((e) => e.name).toList()}");
      setState(() {
        _coordinatingEvents = ordered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      displayMessageToUser("Error loading events: $e", context);
    }
  }

  Future<int> _getEventTeamsCount(String eventId) async {
    try {
      final teamsSnapshot = await FirebaseFirestore.instance
          .collection('Teams')
          .where('eventId', isEqualTo: eventId)
          .get();
      
      return teamsSnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Coordinator Dashboard",
        showBackButton: true,
        onBackPressed: () {
          Navigator.pushReplacementNamed(context, '/home'); // Navigate to the home route
        },
        showProfileButton: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _coordinatingEvents.isEmpty
              ? _buildEmptyState()
              : _buildEventsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "No Events Assigned",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You are not currently coordinating any events.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Events List
          Text(
            "Managing ${_coordinatingEvents.length} event${_coordinatingEvents.length != 1 ? 's' : ''}",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              itemCount: _coordinatingEvents.length,
              itemBuilder: (context, index) {
                final event = _coordinatingEvents[index];
                return _buildEventCard(event);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventParticipantsPage(event: event),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.category.toUpperCase(),
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // const Spacer(),
                  // IconButton(
                  //   onPressed: () {
                  //     // TODO: Edit event functionality
                  //     displayMessageToUser("Edit functionality coming soon!", context);
                  //   },
                  //   icon: const Icon(Icons.edit),
                  //   color: AppTheme.primaryBlue,
                  //   tooltip: "Edit Event",
                  // ),
                ],
              ),
              const SizedBox(height: 12),

              // Event Name
              Text(
                event.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Event Description
              Text(
                event.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),

              // Event Details
              Row(
                children: [
                  _buildInfoChip(
                    Icons.group,
                    "Team: ${event.minTeamSize}-${event.maxTeamSize}",
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.currency_rupee,
                    "₹${event.fee}",
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Teams Count (using FutureBuilder for real-time data)
              FutureBuilder<int>(
                future: _getEventTeamsCount(event.id),
                builder: (context, snapshot) {
                  final teamsCount = snapshot.data ?? 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.groups,
                          color: AppTheme.secondaryPurple,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "$teamsCount team${teamsCount != 1 ? 's' : ''} registered",
                          style: TextStyle(
                            color: AppTheme.secondaryPurple,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}