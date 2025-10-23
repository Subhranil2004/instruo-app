import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/custom_app_bar.dart';
import '../../theme/theme.dart';
import '../../events/events_model.dart';
import '../../helper/helper_functions.dart';
import 'event_update_page.dart';

class EventParticipantsPage extends StatefulWidget {
  final Event event;

  const EventParticipantsPage({super.key, required this.event});

  @override
  State<EventParticipantsPage> createState() => _EventParticipantsPageState();
}

class _EventParticipantsPageState extends State<EventParticipantsPage> {
  List<Map<String, dynamic>> _teams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final firestore = FirebaseFirestore.instance;

      // Step 1: Fetch Event document to retrieve team IDs
      final eventDoc = await firestore
          .collection('Events')
          .doc(widget.event.id)
          .get();

      if (!mounted) return;

      if (!eventDoc.exists) {
        setState(() {
          _teams = [];
          _isLoading = false;
        });
        return;
      }

      final eventData = eventDoc.data();
      final List<String> teamIds = List<String>.from(
        (eventData?['teams'] ?? []).map((value) => value.toString()),
      );

      if (teamIds.isEmpty) {
        setState(() {
          _teams = [];
          _isLoading = false;
        });
        return;
      }

      // Step 2: Fetch all team documents for the collected IDs
      final teamDocs = await Future.wait(
        teamIds.map((teamId) => firestore.collection('Teams').doc(teamId).get()),
      );

      // Step 3: Collect unique member emails (including leads) to batch-fetch user data
      final Set<String> memberEmails = {};
      for (final doc in teamDocs) {
        if (!doc.exists) continue;
        final data = doc.data();
        if (data == null) continue;

        final List<dynamic> membersDynamic = data['members'] ?? [];
        memberEmails.addAll(membersDynamic.map((e) => e.toString()));

        final lead = data['lead'];
        if (lead != null && lead.toString().isNotEmpty) {
          memberEmails.add(lead.toString());
        }
      }

      // Step 4: Fetch user details for every unique member email
      final Map<String, Map<String, dynamic>> usersByEmail = {};
      await Future.wait(memberEmails.map((email) async {
        final userDoc = await firestore.collection('Users').doc(email).get();
        final userData = userDoc.data();
        if (userDoc.exists && userData != null) {
          usersByEmail[email] = {
            'email': email,
            ...userData,
          };
        }
      }));

      // Step 5: Construct enriched team objects for the UI
      final List<Map<String, dynamic>> teams = [];
      for (final doc in teamDocs) {
        if (!doc.exists) continue;
        final data = doc.data();
        if (data == null) continue;

        final String teamId = doc.id;
        final String teamName = data['name']?.toString() ?? 'Unnamed Team';
        final String leadEmail = data['lead']?.toString() ?? '';
        final List<String> members = List<String>.from(
          (data['members'] ?? []).map((e) => e.toString()),
        );

        final List<Map<String, dynamic>> memberDetails = members.map((memberEmail) {
          final userData = usersByEmail[memberEmail];
          final String name = (userData?['name'] ?? '').toString();
          final String collegeName = (userData?['collegeName'] ?? userData?['college'] ?? '').toString();

          return {
            'email': memberEmail,
            'name': name.isNotEmpty ? name : memberEmail,
            'phone': (userData?['phone'] ?? 'N/A').toString(),
            'department': (userData?['department'] ?? 'N/A').toString(),
            'college': collegeName.isNotEmpty ? collegeName : 'N/A',
            'year': (userData?['year'] ?? 'N/A').toString(),
            'isLead': memberEmail == leadEmail,
          };
        }).toList();

        teams.add({
          'id': teamId,
          'name': teamName,
          'lead': leadEmail,
          'members': memberDetails,
          'createdAt': data['createdAt'],
          // include payment screenshot URL if present in the Teams document
          'payment_ss': data.containsKey('payment_ss') ? data['payment_ss'] : '',
        });
      }

      teams.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));

      if (!mounted) return;
      setState(() {
        _teams = teams;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      displayMessageToUser("Error loading teams: $e", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "DASHBOARD",
        showBackButton: true,
        showProfileButton: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _teams.isEmpty
              ? _buildEmptyState()
              : _buildTeamsList(),
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
              Icons.group_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "No Teams Registered",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "No teams have registered for this event yet.",
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

  Widget _buildTeamsList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Info Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.1),
                  AppTheme.secondaryPurple.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      color: AppTheme.primaryBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.event.name,
                        style: Theme.of(context).textTheme.titleLarge
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.category,
                      widget.event.category.toUpperCase(),
                      AppTheme.secondaryPurple,
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      Icons.groups,
                      "${_teams.length} team${_teams.length != 1 ? 's' : ''}",
                      AppTheme.primaryBlue,
                    ),
                    //const SizedBox(width: 12),
                    
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.currency_rupee,
                      "${widget.event.fee} (non-IIESTians)",
                      AppTheme.secondaryPurple,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Teams List Header
          Text(
            "Registered Teams",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 12),

          // Teams List
          Expanded(
            child: ListView.builder(
              itemCount: _teams.length,
              itemBuilder: (context, index) {
                final team = _teams[index];
                return _buildTeamCard(team, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(Map<String, dynamic> team, int teamNumber) {
    final members = List<Map<String, dynamic>>.from(team['members']);
    Map<String, dynamic>? leadMember;
    if (members.isNotEmpty) {
      leadMember = members.firstWhere(
        (member) => member['isLead'] == true,
        orElse: () => members.first,
      );
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryBlue,
          child: Text(
            teamNumber.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          team['name'],
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            "Lead: ${leadMember?['name'] ?? 'N/A'} • ${members.length} member${members.length != 1 ? 's' : ''}",
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: AppTheme.primaryBlue),
              tooltip: 'Edit team',
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventUpdatePage(
                      event: widget.event,
                      team: {
                        ...team,
                        'members': List<Map<String, dynamic>>.from(team['members']),
                      },
                    ),
                  ),
                );

                if (result == true) {
                  _loadTeams();
                }
              },
            ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          const Divider(),
          const SizedBox(height: 8),
          ...members.map((member) => _buildMemberTile(member)),
        ],
      ),
    );
  }

  Widget _buildMemberTile(Map<String, dynamic> member) {
    final String name = (member['name'] ?? '').toString();
    final String email = (member['email'] ?? '').toString();
    final String displayName = name.isNotEmpty ? name : email;
    final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    final String college = (member['college'] ?? 'N/A').toString();
    final String department = (member['department'] ?? 'N/A').toString();
    final String phone = (member['phone'] ?? 'N/A').toString();
    final String year = (member['year'] ?? 'N/A').toString();
    final bool isLead = member['isLead'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLead 
            ? AppTheme.primaryBlue.withOpacity(0.05)
            : AppTheme.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: isLead 
            ? Border.all(color: AppTheme.primaryBlue.withOpacity(0.2))
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isLead 
                ? AppTheme.primaryBlue.withOpacity(0.1)
                : AppTheme.secondaryPurple.withOpacity(0.1),
            child: Text(
              initial,
              style: TextStyle(
                color: isLead ? AppTheme.primaryBlue : AppTheme.secondaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    if (isLead) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "LEAD",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "$college • $department",
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Phone: $phone • $year",
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}