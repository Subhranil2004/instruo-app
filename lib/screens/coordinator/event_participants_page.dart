import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/custom_app_bar.dart';
import '../../theme/theme.dart';
import '../../events/events_model.dart';
import '../../helper/helper_functions.dart';

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
    try {
      // Get teams for this event
      final teamsSnapshot = await FirebaseFirestore.instance
          .collection('Teams')
          .where('eventId', isEqualTo: widget.event.id)
          .get();

      List<Map<String, dynamic>> teams = [];

      for (var teamDoc in teamsSnapshot.docs) {
        final teamData = teamDoc.data();
        final teamMembers = List<String>.from(teamData['members'] ?? []);
        
        // Get member details
        List<Map<String, dynamic>> memberDetails = [];
        for (String memberEmail in teamMembers) {
          try {
            final userDoc = await FirebaseFirestore.instance
                .collection('Users')
                .doc(memberEmail)
                .get();
            
            if (userDoc.exists) {
              final userData = userDoc.data()!;
              memberDetails.add({
                'email': memberEmail,
                'name': userData['name'] ?? 'Unknown',
                'phone': userData['phone'] ?? 'N/A',
                'department': userData['department'] ?? 'N/A',
                'college': userData['college'] ?? 'N/A',
                'year': userData['year'] ?? 'N/A',
                'isLead': memberEmail == teamData['lead'],
              });
            }
          } catch (e) {
            // Skip if user data not found
            continue;
          }
        }

        teams.add({
          'id': teamDoc.id,
          'name': teamData['name'] ?? 'Unnamed Team',
          'lead': teamData['lead'] ?? '',
          'members': memberDetails,
          'createdAt': teamData['createdAt'],
        });
      }

      setState(() {
        _teams = teams;
        _isLoading = false;
      });
    } catch (e) {
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
        title: widget.event.name,
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.category,
                      widget.event.category,
                      AppTheme.primaryBlue,
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      Icons.groups,
                      "${_teams.length} team${_teams.length != 1 ? 's' : ''}",
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
    final leadMember = members.firstWhere(
      (member) => member['isLead'] == true,
      orElse: () => members.first,
    );

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
            "Lead: ${leadMember['name']} • ${members.length} member${members.length != 1 ? 's' : ''}",
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: member['isLead'] 
            ? AppTheme.primaryBlue.withOpacity(0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: member['isLead'] 
            ? Border.all(color: AppTheme.primaryBlue.withOpacity(0.2))
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: member['isLead'] 
                ? AppTheme.primaryBlue.withOpacity(0.1)
                : AppTheme.secondaryPurple.withOpacity(0.1),
            child: Text(
              member['name'][0].toUpperCase(),
              style: TextStyle(
                color: member['isLead'] ? AppTheme.primaryBlue : AppTheme.secondaryPurple,
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
                      member['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    if (member['isLead']) ...[
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
                  "${member['college']} • ${member['department']}",
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Phone: ${member['phone']} • Year: ${member['year']}",
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