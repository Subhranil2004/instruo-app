import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../helper/helper_functions.dart';
import '../../theme/theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/my_button.dart';
import '../../widgets/my_textfield.dart';
import '../../events/events_model.dart';

class EventUpdatePage extends StatefulWidget {
  final Event event;
  final Map<String, dynamic> team;

  const EventUpdatePage({super.key, required this.event, required this.team});

  @override
  State<EventUpdatePage> createState() => _EventUpdatePageState();
}

class _EventUpdatePageState extends State<EventUpdatePage> {
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  List<Map<String, dynamic>> _members = [];

  bool _isLoadingUsers = true;
  bool _showSearch = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  late final Set<String> _originalMemberEmails;
  late final String _leadEmail;

  @override
  void initState() {
    super.initState();
    _teamNameController.text = widget.team['name']?.toString() ?? '';
    _members = List<Map<String, dynamic>>.from(widget.team['members'] ?? []);
    _originalMemberEmails = _members.map((member) => member['email'].toString()).toSet();
    _leadEmail = widget.team['lead']?.toString() ?? '';
    _loadUsers();
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .get();

      if (!mounted) return;

      final users = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              'email': doc.id,
              'name': data['name'] ?? '',
              'phone': data['phone'] ?? '',
              'department': data['department'] ?? '',
              'collegeName': data['collegeName'] ?? data['college'] ?? '',
              'year': data['year'] ?? '',
            };
          })
          .where((user) =>
              user['name'].toString().isNotEmpty &&
              user['phone'].toString().isNotEmpty &&
              user['department'].toString().isNotEmpty &&
              user['collegeName'].toString().isNotEmpty &&
              user['year'].toString().isNotEmpty)
          .toList();

      setState(() {
        _allUsers = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingUsers = false;
      });
      displayMessageToUser('Error loading users: $e', context);
    }
  }

  void _searchUsers(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredUsers = [];
      });
      return;
    }

    final searchQuery = query.toLowerCase();
    final filtered = _allUsers.where((user) {
      final name = user['name'].toString().toLowerCase();
      final phone = user['phone'].toString().toLowerCase();
      return name.contains(searchQuery) || phone.contains(searchQuery);
    }).toList();

    setState(() {
      _filteredUsers = filtered;
    });
  }

  void _addMember(Map<String, dynamic> user) {
    final email = user['email'].toString();

    if (_members.any((member) => member['email'] == email)) {
      displayMessageToUser('User already part of the team', context);
      return;
    }

    if (_members.length >= widget.event.maxTeamSize) {
      displayMessageToUser(
        'Maximum team size (${widget.event.maxTeamSize}) reached',
        context,
      );
      return;
    }

    setState(() {
      _members.add({
        'email': email,
        'name': user['name'] ?? email,
        'phone': user['phone'] ?? 'N/A',
        'department': user['department'] ?? 'N/A',
        'college': user['collegeName'] ?? 'N/A',
        'year': user['year'] ?? 'N/A',
        'isLead': false,
      });
      _searchController.clear();
      _filteredUsers = [];
      _showSearch = false;
    });
  }

  void _removeMember(int index) {
    final member = _members[index];
    if (member['email'] == _leadEmail) {
      displayMessageToUser('Cannot remove the team lead.', context);
      return;
    }

    setState(() {
      _members.removeAt(index);
    });
  }

  Future<void> _updateTeam() async {
    if (_teamNameController.text.trim().isEmpty) {
      displayMessageToUser('Please enter a team name', context);
      return;
    }

    final totalMembers = _members.length;
    if (totalMembers < widget.event.minTeamSize) {
      displayMessageToUser(
        'Minimum team size is ${widget.event.minTeamSize}.',
        context,
      );
      return;
    }

    if (totalMembers > widget.event.maxTeamSize) {
      displayMessageToUser(
        'Maximum team size is ${widget.event.maxTeamSize}.',
        context,
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      final teamId = widget.team['id'].toString();
      final teamRef = firestore.collection('Teams').doc(teamId);

      final memberEmails = _members.map((member) => member['email'].toString()).toList();
      final newMemberEmails = memberEmails.toSet();
      final removedMembers = _originalMemberEmails.difference(newMemberEmails);
      final addedMembers = newMemberEmails.difference(_originalMemberEmails);

      batch.update(teamRef, {
        'name': _teamNameController.text.trim(),
        'members': memberEmails,
        'lead': _leadEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      for (final email in addedMembers) {
        final userRef = firestore.collection('Users').doc(email);
        batch.set(userRef, {
          'eventsRegistered': FieldValue.arrayUnion([widget.event.id]),
        }, SetOptions(merge: true));
      }

      for (final email in removedMembers) {
        final userRef = firestore.collection('Users').doc(email);
        batch.set(userRef, {
          'eventsRegistered': FieldValue.arrayRemove([widget.event.id]),
        }, SetOptions(merge: true));
      }

      await batch.commit();

      if (!mounted) return;
      displayMessageToUser(
        '✅ Team updated successfully!',
        context,
        isError: false,
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      displayMessageToUser('Failed to update team: $e', context);
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _deleteTeam() async {
    // Show confirmation dialog
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Team Registration'),
        content: Text(
          'Are you sure you want to delete the team "${_teamNameController.text.trim()}" from ${widget.event.name}?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      final teamId = widget.team['id'].toString();
      final eventId = widget.event.id;

      // 1. Delete the team document from Teams collection
      final teamRef = firestore.collection('Teams').doc(teamId);
      batch.delete(teamRef);

      // 2. Remove team ID from Events collection's teams list
      final eventRef = firestore.collection('Events').doc(eventId);
      batch.update(eventRef, {
        'teams': FieldValue.arrayRemove([teamId]),
      });

      // 3. Remove event ID from each member's eventsRegistered list
      for (final member in _members) {
        final memberEmail = member['email'].toString();
        final userRef = firestore.collection('Users').doc(memberEmail);
        batch.update(userRef, {
          'eventsRegistered': FieldValue.arrayRemove([eventId]),
        });
      }
      final leadRef = firestore.collection('Users').doc(_leadEmail);
      batch.update(leadRef, {
        'eventsRegistered': FieldValue.arrayRemove([eventId]),
      });

      await batch.commit();

      if (!mounted) return;
      displayMessageToUser(
        '✅ Team registration deleted successfully!',
        context,
        isError: false,
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      displayMessageToUser('Failed to delete team: $e', context);
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Team',
        showBackButton: true,
        showProfileButton: false,
      ),
      body: _isLoadingUsers
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventInfoCard(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Team Details', Icons.edit),
                  const SizedBox(height: 12),
                  MyTextField(
                    controller: _teamNameController,
                    labelText: 'Team Name',
                    hintText: 'Enter team name',
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    'Team Members (${_members.length}/${widget.event.maxTeamSize})',
                    Icons.group,
                  ),
                  const SizedBox(height: 12),
                  if (_members.length < widget.event.maxTeamSize)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showSearch = !_showSearch;
                            if (!_showSearch) {
                              _searchController.clear();
                              _filteredUsers = [];
                            }
                          });
                        },
                        icon: Icon(_showSearch ? Icons.close : Icons.person_add),
                        label: Text(_showSearch ? 'Cancel' : 'Add Member'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue.withOpacity(0.08),
                          foregroundColor: AppTheme.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  if (_showSearch) ...[
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _searchController,
                              style: Theme.of(context).textTheme.bodyMedium,
                              decoration: InputDecoration(
                                labelText: 'Search by name or phone',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _searchController.clear();
                                          _searchUsers('');
                                        },
                                      )
                                    : null,
                              ),
                              onChanged: _searchUsers,
                            ),
                            const SizedBox(height: 16),
                            if (_filteredUsers.isEmpty)
                              Text(
                                'No matching users found',
                                style: TextStyle(color: AppTheme.textSecondary),
                              )
                            else
                              SizedBox(
                                height: 220,
                                child: ListView.separated(
                                  itemCount: _filteredUsers.length,
                                  separatorBuilder: (_, __) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final user = _filteredUsers[index];
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                                        child: Text(
                                          user['name'].toString().isNotEmpty
                                              ? user['name'].toString()[0].toUpperCase()
                                              : user['email'].toString()[0].toUpperCase(),
                                          style: TextStyle(color: AppTheme.primaryBlue),
                                        ),
                                      ),
                                      title: Text(user['name']),
                                      subtitle: Text('${user['phone']} • ${user['department']}'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
                                        color: AppTheme.primaryBlue,
                                        onPressed: () => _addMember(user),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (_members.isEmpty)
                    Text(
                      'This team has no members yet.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _members.length,
                      itemBuilder: (context, index) {
                        final member = _members[index];
                        final bool isLead = member['email'] == _leadEmail;
                        final String displayName =
                            member['name'].toString().isNotEmpty
                                ? member['name'].toString()
                                : member['email'].toString();
                        final String initial =
                            displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
                        final String college =
                            (member['college'] ?? 'N/A').toString();
                        final String department =
                            (member['department'] ?? 'N/A').toString();
                        final String phone = (member['phone'] ?? 'N/A').toString();
                        final String year = (member['year'] ?? 'N/A').toString();
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
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
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    displayName,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                if (isLead)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryBlue,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'LEAD',
                                      style: TextStyle(color: Colors.white, fontSize: 10),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$college • $department'),
                                Text('Phone: $phone • $year'),
                              ],
                            ),
                            trailing: isLead
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    color: Colors.redAccent,
                                    onPressed: () => _removeMember(index),
                                  ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 32),
                    // Payment screenshot preview (if available in team data)
                  
                  if (widget.team.containsKey('payment_ss') && (widget.team['payment_ss'] ?? '').toString().isNotEmpty) ...[
                    _buildPaymentSSPreview(widget.team['payment_ss'].toString()),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 32),
                  MyButton(
                    onTap: _isUpdating || _isDeleting ? null : _updateTeam,
                    text: _isUpdating ? 'Saving...' : 'Save Changes',
                  ),
                  const SizedBox(height: 16),
                  MyButton(
                    onTap: _isUpdating || _isDeleting ? null : _deleteTeam,
                    text: _isDeleting ? 'Deleting...' : 'Delete Registration',
                    backgroundColor: _isUpdating || _isDeleting ? Colors.grey : Colors.red,
                    textColor: Colors.white,
                    icon: _isDeleting 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.delete_forever, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPaymentSSPreview(String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Payment Screenshot', Icons.image),
        const SizedBox(height: 8),
        ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              // height: 140,
              // width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 140,
                color: Colors.grey.shade200,
                child: Center(child: Text('Unable to load image', style: TextStyle(color: AppTheme.textSecondary))),
              ),
            ),
          ),
        // ),
      ],
    );
  }

  Widget _buildEventInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryBlue.withOpacity(0.1),
              AppTheme.secondaryPurple.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.event.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.people,
              'Team Size',
              '${widget.event.minTeamSize} - ${widget.event.maxTeamSize}',
            ),
            _buildInfoRow(
              Icons.currency_rupee,
              'Registration Fee',
              '₹${widget.event.fee} (non-IIESTians)',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 18),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
