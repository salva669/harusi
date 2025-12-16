import 'package:flutter/material.dart';
import '../models/wedding.dart';
import '../models/guest.dart';
import '../models/guest_pledge.dart';
import '../models/pledge_payment.dart';
import '../services/api_service.dart';

class GuestsScreen extends StatefulWidget {
  final Wedding wedding;

  const GuestsScreen({Key? key, required this.wedding}) : super(key: key);

  @override
  State<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends State<GuestsScreen> {
  List<Guest> _allGuests = [];
  List<Guest> _filteredGuests = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterStatus = 'all';
  String _sortBy = 'name';

  @override
  void initState() {
    super.initState();
    _loadGuests();
  }

  Future<void> _loadGuests() async {
    setState(() => _isLoading = true);
    try {
      final guests = await ApiService.getGuests(widget.wedding.id!);
      setState(() {
        _allGuests = guests;
        _filterAndSortGuests();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading guests: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterAndSortGuests() {
    _filteredGuests = _allGuests.where((guest) {
      final matchesSearch = guest.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (guest.phone?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (guest.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final matchesStatus = _filterStatus == 'all' || guest.rsvpStatus == _filterStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    switch (_sortBy) {
      case 'name':
        _filteredGuests.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'status':
        _filteredGuests.sort((a, b) {
          final statusOrder = {'confirmed': 1, 'pending': 2, 'declined': 3};
          return (statusOrder[a.rsvpStatus] ?? 4).compareTo(statusOrder[b.rsvpStatus] ?? 4);
        });
        break;
      case 'guests':
        _filteredGuests.sort((a, b) => b.numberOfGuests.compareTo(a.numberOfGuests));
        break;
    }
  }

  Map<String, dynamic> _getGuestStats() {
    final confirmed = _allGuests.where((g) => g.rsvpStatus == 'confirmed').length;
    final pending = _allGuests.where((g) => g.rsvpStatus == 'pending').length;
    final declined = _allGuests.where((g) => g.rsvpStatus == 'declined').length;
    final totalPeople = _allGuests.fold<int>(0, (sum, g) => sum + g.numberOfGuests);
    final confirmedPeople = _allGuests
        .where((g) => g.rsvpStatus == 'confirmed')
        .fold<int>(0, (sum, g) => sum + g.numberOfGuests);
    
    final withDietary = _allGuests
        .where((g) => g.dietaryRestrictions != null && g.dietaryRestrictions!.isNotEmpty)
        .length;
    
    final byRelationship = <String, int>{};
    for (var guest in _allGuests) {
      final rel = guest.relationship ?? 'other';
      byRelationship[rel] = (byRelationship[rel] ?? 0) + 1;
    }

    return {
      'confirmed': confirmed,
      'pending': pending,
      'declined': declined,
      'total': _allGuests.length,
      'totalPeople': totalPeople,
      'confirmedPeople': confirmedPeople,
      'withDietary': withDietary,
      'byRelationship': byRelationship,
    };
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getRelationshipIcon(String? relationship) {
    switch (relationship) {
      case 'family':
        return Icons.family_restroom;
      case 'friend':
        return Icons.people;
      case 'colleague':
        return Icons.business_center;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = _getGuestStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guests'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: 'Sort',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Guest List'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'stats',
                child: Row(
                  children: [
                    Icon(Icons.analytics),
                    SizedBox(width: 8),
                    Text('View Analytics'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'bulk_message',
                child: Row(
                  children: [
                    Icon(Icons.message),
                    SizedBox(width: 8),
                    Text('Send Bulk Message'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'stats') {
                _showStatsDialog(stats);
              } else if (value == 'export') {
                _exportGuestList();
              } else if (value == 'bulk_message') {
                _showBulkMessageDialog();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('Total', stats['total']!, Icons.people, Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('Confirmed', stats['confirmed']!, Icons.check_circle, Colors.green),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('Pending', stats['pending']!, Icons.pending, Colors.orange),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.group, color: Theme.of(context).primaryColor, size: 20),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${stats['totalPeople']} Total',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${stats['confirmedPeople']} Confirmed',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (stats['withDietary']! > 0) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.restaurant_menu, color: Colors.deepOrange, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '${stats['withDietary']} Dietary',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, phone, or email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _filterAndSortGuests();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filterAndSortGuests();
                });
              },
            ),
          ),
          if (_filterStatus != 'all' || _sortBy != 'name')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (_filterStatus != 'all')
                    Chip(
                      label: Text('Filter: ${_filterStatus.toUpperCase()}'),
                      backgroundColor: _getStatusColor(_filterStatus).withOpacity(0.1),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _filterStatus = 'all';
                          _filterAndSortGuests();
                        });
                      },
                    ),
                  if (_sortBy != 'name') ...[
                    const SizedBox(width: 8),
                    Chip(
                      label: Text('Sort: $_sortBy'),
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _sortBy = 'name';
                          _filterAndSortGuests();
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredGuests.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty || _filterStatus != 'all'
                                  ? 'No guests match your search'
                                  : 'No guests yet',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                            if (_searchQuery.isEmpty && _filterStatus == 'all') ...[
                              const SizedBox(height: 8),
                              Text(
                                'Tap + to add your first guest',
                                style: TextStyle(color: Colors.grey[500], fontSize: 14),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadGuests,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredGuests.length,
                          itemBuilder: (context, index) => _buildGuestCard(_filteredGuests[index]),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGuestDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Guest'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildGuestCard(Guest guest) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showGuestDetailsDialog(guest),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _getStatusColor(guest.rsvpStatus).withOpacity(0.2),
                radius: 28,
                child: Icon(_getRelationshipIcon(guest.relationship), color: _getStatusColor(guest.rsvpStatus), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(guest.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(guest.rsvpStatus),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            guest.rsvpStatus.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.group, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${guest.numberOfGuests} guest${guest.numberOfGuests > 1 ? 's' : ''}',
                            style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                        if (guest.relationship != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.label, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(guest.relationship!, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                        ],
                      ],
                    ),
                    if (guest.phone != null && guest.phone!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(guest.phone!, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                        ],
                      ),
                    ],
                    if (guest.dietaryRestrictions != null && guest.dietaryRestrictions!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.restaurant, size: 14, color: Colors.orange[700]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              guest.dietaryRestrictions!,
                              style: TextStyle(fontSize: 12, color: Colors.orange[700], fontStyle: FontStyle.italic),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit')])),
                  const PopupMenuItem(value: 'pledge', child: Row(children: [Icon(Icons.volunteer_activism, size: 20), SizedBox(width: 8), Text('Manage Pledge')])),
                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                ],
                onSelected: (value) {
                  if (value == 'edit') _showEditGuestDialog(guest);
                  else if (value == 'pledge') _showPledgeDialog(guest);
                  else if (value == 'delete') _deleteGuest(guest);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGuestDetailsDialog(Guest guest) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getStatusColor(guest.rsvpStatus).withOpacity(0.2),
              child: Icon(_getRelationshipIcon(guest.relationship), color: _getStatusColor(guest.rsvpStatus)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(guest.name, style: const TextStyle(fontSize: 18))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Status', guest.rsvpStatus.toUpperCase(), color: _getStatusColor(guest.rsvpStatus)),
              const Divider(),
              _buildDetailRow('Number of Guests', guest.numberOfGuests.toString()),
              if (guest.relationship != null) _buildDetailRow('Relationship', guest.relationship!),
              if (guest.phone != null && guest.phone!.isNotEmpty) _buildDetailRow('Phone', guest.phone!),
              if (guest.email != null && guest.email!.isNotEmpty) _buildDetailRow('Email', guest.email!),
              if (guest.dietaryRestrictions != null && guest.dietaryRestrictions!.isNotEmpty) ...[
                const Divider(),
                const Text('Dietary Restrictions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                Text(guest.dietaryRestrictions!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showEditGuestDialog(guest);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 13, color: color))),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('Name (A-Z)'),
              value: 'name',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                  _filterAndSortGuests();
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('Status'),
              value: 'status',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                  _filterAndSortGuests();
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('Number of Guests'),
              value: 'guests',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                  _filterAndSortGuests();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Guests'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(title: const Text('All'), value: 'all', groupValue: _filterStatus, onChanged: (value) {
              setState(() {
                _filterStatus = value!;
                _filterAndSortGuests();
              });
              Navigator.pop(context);
            }),
            RadioListTile(title: const Text('Confirmed'), value: 'confirmed', groupValue: _filterStatus, onChanged: (value) {
              setState(() {
                _filterStatus = value!;
                _filterAndSortGuests();
              });
              Navigator.pop(context);
            }),
            RadioListTile(title: const Text('Pending'), value: 'pending', groupValue: _filterStatus, onChanged: (value) {
              setState(() {
                _filterStatus = value!;
                _filterAndSortGuests();
              });
              Navigator.pop(context);
            }),
            RadioListTile(title: const Text('Declined'), value: 'declined', groupValue: _filterStatus, onChanged: (value) {
              setState(() {
                _filterStatus = value!;
                _filterAndSortGuests();
              });
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  void _showStatsDialog(Map<String, dynamic> stats) {
    final byRelationship = stats['byRelationship'] as Map<String, int>;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guest Analytics'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('RSVP Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              _buildStatRow('Total Invited', stats['total'].toString(), Colors.blue),
              _buildStatRow('Confirmed', stats['confirmed'].toString(), Colors.green),
              _buildStatRow('Pending', stats['pending'].toString(), Colors.orange),
              _buildStatRow('Declined', stats['declined'].toString(), Colors.red),
              const Divider(height: 24),
              const Text('Headcount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              _buildStatRow('Total Expected', stats['totalPeople'].toString(), Colors.blue),
              _buildStatRow('Confirmed Attending', stats['confirmedPeople'].toString(), Colors.green),
              if (stats['withDietary'] > 0) ...[
                const Divider(height: 24),
                _buildStatRow('Guests with Dietary Needs', stats['withDietary'].toString(), Colors.deepOrange),
              ],
              if (byRelationship.isNotEmpty) ...[
                const Divider(height: 24),
                const Text('By Relationship', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ...byRelationship.entries.map((entry) => 
                  _buildStatRow(_capitalize(entry.key), entry.value.toString(), Colors.grey[700]!)
                ),
              ],
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  void _exportGuestList() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon!'), backgroundColor: Colors.blue),
    );
  }

  void _showBulkMessageDialog() {
    final messageController = TextEditingController();
    String targetGroup = 'all';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Send Bulk Message'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: targetGroup,
                  decoration: const InputDecoration(labelText: 'Send To', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Guests')),
                    DropdownMenuItem(value: 'confirmed', child: Text('Confirmed Only')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending Only')),
                  ],
                  onChanged: (value) => setDialogState(() => targetGroup = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                    hintText: 'Enter your message here...',
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton.icon(
              onPressed: () {
                if (messageController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a message')),
                  );
                  return;
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bulk message feature coming soon!'), backgroundColor: Colors.blue),
                );
              },
              icon: const Icon(Icons.send),
              label: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessageToGuest(Guest guest) {
    if (guest.phone == null || guest.phone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number for this guest')),
      );
      return;
    }

    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Message to ${guest.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Phone: ${guest.phone}', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
                hintText: 'Enter your message...',
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () {
              if (messageController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a message')),
                );
                return;
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Message sent to ${guest.name}'), backgroundColor: Colors.green),
              );
            },
            icon: const Icon(Icons.send),
            label: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showAddGuestDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final dietaryController = TextEditingController();
    String relationship = 'friend';
    String rsvpStatus = 'pending';
    int numberOfGuests = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Guest'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name *', border: OutlineInputBorder()),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder(), prefixText: '+255 '),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: relationship,
                  decoration: const InputDecoration(labelText: 'Relationship', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'family', child: Text('Family')),
                    DropdownMenuItem(value: 'friend', child: Text('Friend')),
                    DropdownMenuItem(value: 'colleague', child: Text('Colleague')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) => setDialogState(() => relationship = value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: rsvpStatus,
                  decoration: const InputDecoration(labelText: 'RSVP Status', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                    DropdownMenuItem(value: 'declined', child: Text('Declined')),
                  ],
                  onChanged: (value) => setDialogState(() => rsvpStatus = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: 'Number of Guests', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: numberOfGuests.toString()),
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null && parsed > 0) numberOfGuests = parsed;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dietaryController,
                  decoration: const InputDecoration(labelText: 'Dietary Restrictions (Optional)', border: OutlineInputBorder()),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a name')));
                  return;
                }
                try {
                  final guest = Guest(
                    weddingId: widget.wedding.id!,
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : '',
                    email: emailController.text.trim().isNotEmpty ? emailController.text.trim() : '',
                    relationship: relationship,
                    rsvpStatus: rsvpStatus,
                    numberOfGuests: numberOfGuests,
                    dietaryRestrictions: dietaryController.text.trim().isNotEmpty ? dietaryController.text.trim() : '',
                  );
                  await ApiService.createGuest(widget.wedding.id!, guest);
                  Navigator.pop(context);
                  _loadGuests();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Guest added successfully'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditGuestDialog(Guest guest) {
    final nameController = TextEditingController(text: guest.name);
    final phoneController = TextEditingController(text: guest.phone ?? '');
    final emailController = TextEditingController(text: guest.email ?? '');
    final dietaryController = TextEditingController(text: guest.dietaryRestrictions ?? '');
    String relationship = guest.relationship ?? 'friend';
    String rsvpStatus = guest.rsvpStatus;
    int numberOfGuests = guest.numberOfGuests;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Guest'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name *', border: OutlineInputBorder()),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: relationship,
                  decoration: const InputDecoration(labelText: 'Relationship', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'family', child: Text('Family')),
                    DropdownMenuItem(value: 'friend', child: Text('Friend')),
                    DropdownMenuItem(value: 'colleague', child: Text('Colleague')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) => setDialogState(() => relationship = value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: rsvpStatus,
                  decoration: const InputDecoration(labelText: 'RSVP Status', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                    DropdownMenuItem(value: 'declined', child: Text('Declined')),
                  ],
                  onChanged: (value) => setDialogState(() => rsvpStatus = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: 'Number of Guests', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: numberOfGuests.toString()),
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null && parsed > 0) numberOfGuests = parsed;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dietaryController,
                  decoration: const InputDecoration(labelText: 'Dietary Restrictions (Optional)', border: OutlineInputBorder()),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a name')));
                  return;
                }
                try {
                  final updatedGuest = Guest(
                    id: guest.id,
                    weddingId: widget.wedding.id!,
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : '',
                    email: emailController.text.trim().isNotEmpty ? emailController.text.trim() : '',
                    relationship: relationship,
                    rsvpStatus: rsvpStatus,
                    numberOfGuests: numberOfGuests,
                    dietaryRestrictions: dietaryController.text.trim().isNotEmpty ? dietaryController.text.trim() : '',
                  );
                  await ApiService.updateGuest(widget.wedding.id!, guest.id!, updatedGuest);
                  Navigator.pop(context);
                  _loadGuests();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Guest updated successfully'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteGuest(Guest guest) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Guest'),
        content: Text('Are you sure you want to delete ${guest.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && guest.id != null) {
      try {
        await ApiService.deleteGuest(widget.wedding.id!, guest.id!);
        _loadGuests();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Guest deleted successfully'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _showPledgeDialog(Guest guest) async {
    try {
      final pledges = await ApiService.getPledges(widget.wedding.id!);
      final guestPledges = pledges.where((p) => p.guestId == guest.id).toList();
      if (guestPledges.isEmpty) {
        _showCreatePledgeDialog(guest);
      } else {
        _showPledgeManagementDialog(guest, guestPledges.first);
      }
    } catch (e) {
      _showCreatePledgeDialog(guest);
    }
  }

  void _showCreatePledgeDialog(Guest guest) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    String paymentMethod = 'cash';
    DateTime? deadline;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Record Pledge - ${guest.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Pledged Amount (TZS) *', border: OutlineInputBorder(), prefixText: 'TZS '),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: paymentMethod,
                  decoration: const InputDecoration(labelText: 'Payment Method', border: OutlineInputBorder()),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Cash', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: 'mobile_money', child: Text('Mobile Money', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: 'cheque', child: Text('Cheque', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(value: 'other', child: Text('Other', overflow: TextOverflow.ellipsis)),
                  ],
                  onChanged: (value) => setDialogState(() => paymentMethod = value!),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: widget.wedding.weddingDate,
                    );
                    if (picked != null) {
                      setDialogState(() => deadline = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Payment Deadline (Optional)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      deadline != null ? _formatDate(deadline!) : 'Tap to select deadline',
                      style: TextStyle(color: deadline != null ? Colors.black : Colors.grey[600]),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes (Optional)', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (amountController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter pledge amount')));
                  return;
                }
                try {
                  // Don't send pledge_date - it's auto-generated by Django
                  final pledgeData = {
                    'guest': guest.id!,
                    'wedding': widget.wedding.id!,
                    'pledged_amount': double.parse(amountController.text),
                    'paid_amount': 0,
                    'payment_method': paymentMethod,
                    if (deadline != null) 'payment_deadline': deadline!.toIso8601String().split('T')[0],
                    if (notesController.text.trim().isNotEmpty) 'notes': notesController.text.trim(),
                  };
                  
                  await ApiService.createPledge(widget.wedding.id!, GuestPledge.fromJson({
                    ...pledgeData,
                    'id': 0,
                    'balance': 0,
                    'payment_status': 'pledged',
                    'pledge_date': DateTime.now().toIso8601String(),
                  }));
                  
                  Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pledge recorded successfully'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Record Pledge'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPledgeManagementDialog(Guest guest, GuestPledge pledge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pledge - ${guest.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPledgeInfoCard('Pledged Amount', 'TZS ${pledge.pledgedAmount.toStringAsFixed(0)}', Colors.blue),
              const SizedBox(height: 8),
              _buildPledgeInfoCard('Paid Amount', 'TZS ${pledge.paidAmount.toStringAsFixed(0)}', Colors.green),
              const SizedBox(height: 8),
              _buildPledgeInfoCard('Balance', 'TZS ${pledge.balance.toStringAsFixed(0)}', pledge.balance > 0 ? Colors.orange : Colors.green),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getPledgeStatusColor(pledge.paymentStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getPledgeStatusColor(pledge.paymentStatus)),
                ),
                child: Row(
                  children: [
                    Icon(_getPledgeStatusIcon(pledge.paymentStatus), color: _getPledgeStatusColor(pledge.paymentStatus)),
                    const SizedBox(width: 8),
                    Text('Status: ${_getPledgeStatusLabel(pledge.paymentStatus)}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: _getPledgeStatusColor(pledge.paymentStatus))),
                  ],
                ),
              ),
              if (pledge.paymentDeadline != null) ...[
                const SizedBox(height: 12),
                Row(children: [const Icon(Icons.alarm, size: 16), const SizedBox(width: 4), Text('Deadline: ${_formatDate(pledge.paymentDeadline!)}')]),
              ],
              if (pledge.notes != null && pledge.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Notes: ${pledge.notes}', style: const TextStyle(fontSize: 13)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          if (pledge.balance > 0)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showRecordPaymentDialog(guest, pledge);
              },
              icon: const Icon(Icons.payment),
              label: const Text('Record Payment'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
        ],
      ),
    );
  }

  Widget _buildPledgeInfoCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Color _getPledgeStatusColor(String status) {
    switch (status) {
      case 'paid': return Colors.green;
      case 'partial': return Colors.orange;
      case 'pledged': return Colors.blue;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getPledgeStatusIcon(String status) {
    switch (status) {
      case 'paid': return Icons.check_circle;
      case 'partial': return Icons.timelapse;
      case 'pledged': return Icons.pending;
      case 'cancelled': return Icons.cancel;
      default: return Icons.help;
    }
  }

  String _getPledgeStatusLabel(String status) {
    switch (status) {
      case 'paid': return 'Fully Paid';
      case 'partial': return 'Partially Paid';
      case 'pledged': return 'Pledged';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }

  void _showRecordPaymentDialog(Guest guest, GuestPledge pledge) {
    final amountController = TextEditingController();
    final referenceController = TextEditingController();
    final notesController = TextEditingController();
    String paymentMethod = pledge.paymentMethod ?? 'cash';
    DateTime paymentDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Record Payment - ${guest.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Outstanding Balance:'),
                      Text('TZS ${pledge.balance.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Payment Amount (TZS) *',
                    border: const OutlineInputBorder(),
                    prefixText: 'TZS ',
                    helperText: 'Max: ${pledge.balance.toStringAsFixed(0)}',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(context: context, initialDate: paymentDate, firstDate: DateTime(2020), lastDate: DateTime.now());
                    if (picked != null) setDialogState(() => paymentDate = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Payment Date', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
                    child: Text(_formatDate(paymentDate)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: paymentMethod,
                  decoration: const InputDecoration(labelText: 'Payment Method', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'mobile_money', child: Text('Mobile Money')),
                    DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
                    DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) => setDialogState(() => paymentMethod = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: referenceController,
                  decoration: const InputDecoration(labelText: 'Reference Number (Optional)', border: OutlineInputBorder(), hintText: 'Transaction ID, Receipt No, etc'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes (Optional)', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (amountController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter payment amount')));
                  return;
                }
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount')));
                  return;
                }
                if (amount > pledge.balance) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Amount cannot exceed outstanding balance')));
                  return;
                }
                try {
                  // Create the payment record
                  final payment = PledgePayment(
                    pledgeId: pledge.id!,
                    amount: amount,
                    paymentDate: paymentDate,
                    paymentMethod: paymentMethod,
                    referenceNumber: referenceController.text.trim().isNotEmpty ? referenceController.text.trim() : null,
                    notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
                  );
                  
                  // Record the payment via API
                  await ApiService.recordPledgePayment(widget.wedding.id!, pledge.id!, payment);
                  
                  Navigator.pop(context);
                  
                  // Refresh the guest list to get updated pledge data
                  _loadGuests();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment recorded successfully'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Record Payment'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}