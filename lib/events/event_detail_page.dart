import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instruo_application/events/fifa_register_page.dart';
import 'package:instruo_application/events/kings_con_register_page.dart';
import 'package:instruo_application/events/ode_to_code_register_page.dart';
import 'package:instruo_application/helper/helper_functions.dart';
import 'events_model.dart';
import "../theme/theme.dart";
import "../widgets/app_drawer.dart";
import 'event_register_page.dart';

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
      setState(() => _isLoading = false);
      return;
    }

    try {
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
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.4,
                pinned: true,
                backgroundColor: Colors.black,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    widget.event.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(1, 1))],
                    ),
                  ),
                  background: Hero(
                    tag: widget.event.name,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(widget.event.image, fit: BoxFit.cover),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black54]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description (copyable)
                        SelectableText(
                          widget.event.description,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 30),

                        // Rules Button
                        if (widget.event.rules.isNotEmpty)
                        Center(
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.transparent,
                              child: InkWell(
                              onTap: () {
                                launchDialer(widget.event.rules, context, isUrl: true);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withOpacity(0.1), // translucent
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.primaryBlue.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.rule, color: AppTheme.primaryBlue),
                                    const SizedBox(width: 8),
                                    Text(
                                      "View Rules",
                                      style: TextStyle(
                                        color: AppTheme.primaryBlue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          "Prize Pool:",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        if (widget.event.prizePool.isNotEmpty)
                          Center(
                            child: Wrap(
                              spacing: 6, // horizontal spacing between chips
                              runSpacing: 6, // vertical spacing between lines
                              alignment: WrapAlignment.center,
                              children: widget.event.prizePool.entries.map((e) {
                                return Chip(
                                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                                  label: Text(
                                    "₹${e.value}",
                                    style: TextStyle(
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),


                        const SizedBox(height: 20),
                        Text(
                          "Event Coordinator(s):",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        if (widget.event.coordinators.isNotEmpty)
                          Column(
                            children: widget.event.coordinators.map((coordinator) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.primaryBlue.withOpacity(0.1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                                      radius: 24,
                                      child: Text(
                                        coordinator.name.isNotEmpty
                                            ? coordinator.name[0].toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          color: AppTheme.primaryBlue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            coordinator.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Coordinator",
                                            style: TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.phone, color: Colors.green),
                                      tooltip: "Call ${coordinator.name}",
                                      onPressed: () => launchDialer(coordinator.phone, context),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                        else
                          const Text("Details will be announced soon."),
                        const SizedBox(height: 200), // extra bottom padding
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Floating register/edit button
          if (!_isLoading)
            Positioned(
              bottom: 50,
              right: 20,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (_isRegistered) {
                      displayMessageToUser("ℹ️ Contact the coordinator for editing your registration.", context, isError: false, durationSeconds: 2);
                    } else {
                      // If event is in Robotics category or one of specific events, direct to GForm
                      final eventId = widget.event.id;
                      final eventCategory = widget.event.category.toLowerCase();
                      const gformEvents = ['gen1', 'gen3', 'tech7', 'game3', 'game2'];
                      const separateformEvents = ['tech8', 'game1', 'game4'];
                      const physicalRegnEvents = ['gen12', 'game5'];

                      if (eventCategory == 'robotics' || gformEvents.contains(eventId)) {
                        displayMessageToUser('Register through Google Form', context, isError: false, durationSeconds: 3);
                        launchDialer(widget.event.gform, context, isUrl: true);
                        return;
                      }

                      if(separateformEvents.contains(eventId)) {

                        switch(eventId) {
                          case 'tech8':
                            Navigator.push(context, MaterialPageRoute(builder: (context) => OdeToCodeRegisterPage(event: widget.event))).then((_) => _checkRegistrationStatus());
                        return;
                          case 'game1':
                            Navigator.push(context, MaterialPageRoute(builder: (context) => FifaRegisterPage(event: widget.event))).then((_) => _checkRegistrationStatus());
                        return;
                          case 'game4':
                            Navigator.push(context, MaterialPageRoute(builder: (context) => KingsConRegisterPage(event: widget.event))).then((_) => _checkRegistrationStatus());
                        return;
                        }

                      }

                      if (physicalRegnEvents.contains(eventId)) {
                        displayMessageToUser('Registration for this event will be done physically at the Lords Ground', context, isError: false, durationSeconds: 3);
                        return;
                      }

                      Navigator.push(context, MaterialPageRoute(builder: (context) => EventRegisterPage(event: widget.event))).then((_) => _checkRegistrationStatus());
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: (_isRegistered ? AppTheme.secondaryPurple : AppTheme.primaryBlue).withOpacity(0.1), // soft translucent background
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (_isRegistered ? AppTheme.secondaryPurple : AppTheme.primaryBlue).withOpacity(0.3), // subtle border
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_isRegistered ? Icons.edit : Icons.person_add, color: _isRegistered ? AppTheme.secondaryPurple : AppTheme.primaryBlue),
                        const SizedBox(width: 8),
                        Text(
                          _isRegistered ? "Edit Registration" : "Register",
                          style: TextStyle(color: _isRegistered ? AppTheme.secondaryPurple : AppTheme.primaryBlue, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
