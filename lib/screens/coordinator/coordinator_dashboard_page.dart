import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/custom_app_bar.dart';
import '../../theme/theme.dart';
import '../../events/events_model.dart';
import '../../events/events_info.dart';
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

      if (!mounted) return;

      if (userDoc.exists) {
        final userData = userDoc.data();
        final isCoordinator = userData?['isCoordinator'] ?? false;
        
        if (!isCoordinator) {
          if (!mounted) return;
          displayMessageToUser("Access denied. Coordinator privileges required.", context);
          Navigator.pop(context);
          return;
        }

        setState(() {
          // User is confirmed as coordinator, proceed to load events
        });

        await _loadCoordinatedEvents();
        if (!mounted) return;
      } else {
        if (!mounted) return;
        displayMessageToUser("User data not found", context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
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

      if (!mounted) return;

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

      final Map<String, Event> catalog = {
        for (final event in events) event.id: event,
      };

      List<Event> resolvedEvents;
      if (coordIds.contains('all')) {
        resolvedEvents = List<Event>.from(events)..sort((a, b) => a.name.compareTo(b.name));
      } else {
        resolvedEvents = coordIds
            .map((id) => catalog[id])
            .whereType<Event>()
            .toList();
      }

      if (resolvedEvents.isEmpty && coordIds.isNotEmpty) {
        if (!mounted) return;
        displayMessageToUser(
          "No matching events found in catalog for assigned IDs.",
          context,
        );
      }

      if (!mounted) return;
      setState(() {
        _coordinatingEvents = resolvedEvents;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
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
        title: "COORDINATOR DASHBOARD",
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
          const SizedBox(height: 12),
          // Events List
          Center(
            child: Text(
              "Managing ${_coordinatingEvents.length} event${_coordinatingEvents.length != 1 ? 's' : ''}",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView.separated(
              itemCount: _coordinatingEvents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final event = _coordinatingEvents[index];
                return _buildEventTile(event);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTile(Event event) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventParticipantsPage(event: event),
            ),
          );
        },
        // Make the left content flexible so long event names ellipsize instead of overflowing
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                event.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _buildInfoChip(Icons.category, event.category.toUpperCase()),
          ],
        ),
        // subtitle: Padding(
        //   padding: const EdgeInsets.only(top: 6),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       // Text(
        //       //   event.description,
        //       //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        //       //         color: AppTheme.textSecondary,
        //       //       ),
        //       //   maxLines: 2,
        //       //   overflow: TextOverflow.ellipsis,
        //       // ),
        //       // const SizedBox(height: 8),
        //       // Wrap(
        //       //   spacing: 8,
        //       //   runSpacing: 8,
        //       //   children: [
        //       //     _buildInfoChip(Icons.category, event.category.toUpperCase()),
        //       //     _buildInfoChip(
        //       //       Icons.group,
        //       //       "${event.minTeamSize}-${event.maxTeamSize} members",
        //       //     ),
        //       //     _buildInfoChip(
        //       //       Icons.currency_rupee,
        //       //       "₹${event.fee}",
        //       //     ),
        //       //   ],
        //       // ),
        //     ],
        //   ),
        // ),
        // Constrain trailing width so it cannot force the title row to overflow
        trailing: IntrinsicWidth(
          child: FutureBuilder<int>(
            future: _getEventTeamsCount(event.id),
            builder: (context, snapshot) {
              final teamsCount = snapshot.data ?? 0;
              return IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VerticalDivider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                      width: 24,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.groups, color: AppTheme.secondaryPurple, size: 20),
                        const SizedBox(height: 4),
                        Text(
                          "$teamsCount team${teamsCount != 1 ? 's' : ''}",
                          style: TextStyle(
                            color: AppTheme.secondaryPurple,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
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