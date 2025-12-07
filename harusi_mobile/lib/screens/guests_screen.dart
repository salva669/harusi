import 'package:flutter/material.dart';
import '../models/wedding.dart';
import '../models/guest.dart';
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
  String _filterStatus = 'all'; // all, confirmed, pending, declined

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
        _filterGuests();
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

  void _filterGuests() {
    _filteredGuests = _allGuests.where((guest) {
      final matchesSearch = guest.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _filterStatus == 'all' || guest.rsvpStatus == _filterStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  Map<String, int> _getGuestStats() {
    final confirmed = _allGuests.where((g) => g.rsvpStatus == 'confirmed').length;
    final pending = _allGuests.where((g) => g.rsvpStatus == 'pending').length;
    final declined = _allGuests.where((g) => g.rsvpStatus == 'declined').length;
    final totalPeople = _allGuests.fold<int>(0, (sum, g) => sum + g.numberOfGuests);
    return {
      'confirmed': confirmed,
      'pending': pending,
      'declined': declined,
      'total': _allGuests.length,
      'totalPeople': totalPeople,
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

  IconData _getRelationshipIcon(String relationship) {
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
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Cards
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total',
                        stats['total']!,
                        Icons.people,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Confirmed',
                        stats['confirmed']!,
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Pending',
                        stats['pending']!,
                        Icons.pending,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
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
                      Icon(Icons.group, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Total People: ${stats['totalPeople']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search guests...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filterGuests();
                });
              },
            ),
          ),

          // Guest List
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
                              _searchQuery.isNotEmpty ? 'No guests found' : 'No guests yet',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                            if (_searchQuery.isEmpty) ...[
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
                          itemBuilder: (context, index) {
                            final guest = _filteredGuests[index];
                            return _buildGuestCard(guest);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGuestDialog(),
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
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCard(Guest guest) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(guest.rsvpStatus).withOpacity(0.2),
          child: Icon(
            _getRelationshipIcon(guest.relationship),
            color: _getStatusColor(guest.rsvpStatus),
          ),
        ),
        title: Text(
          guest.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (guest.phone != null && guest.phone!.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(guest.phone!),
                ],
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.group, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${guest.numberOfGuests} guest(s)'),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(guest.rsvpStatus),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    guest.rsvpStatus.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (guest.dietaryRestrictions != null && guest.dietaryRestrictions!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.restaurant, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      guest.dietaryRestrictions!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showEditGuestDialog(guest);
            } else if (value == 'delete') {
              _deleteGuest(guest);
            }
          },
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
            RadioListTile(
              title: const Text('All'),
              value: 'all',
              groupValue: _filterStatus,
              onChanged: (value) {
                setState(() {
                  _filterStatus = value!;
                  _filterGuests();
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('Confirmed'),
              value: 'confirmed',
              groupValue: _filterStatus,
              onChanged: (value) {
                setState(() {
                  _filterStatus = value!;
                  _filterGuests();
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('Pending'),
              value: 'pending',
              groupValue: _filterStatus,
              onChanged: (value) {
                setState(() {
                  _filterStatus = value!;
                  _filterGuests();
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('Declined'),
              value: 'declined',
              groupValue: _filterStatus,
              onChanged: (value) {
                setState(() {
                  _filterStatus = value!;
                  _filterGuests();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
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
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                    prefixText: '+255 ',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: relationship,
                  decoration: const InputDecoration(
                    labelText: 'Relationship',
                    border: OutlineInputBorder(),
                  ),
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
                  decoration: const InputDecoration(
                    labelText: 'RSVP Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                    DropdownMenuItem(value: 'declined', child: Text('Declined')),
                  ],
                  onChanged: (value) => setDialogState(() => rsvpStatus = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Number of Guests',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: numberOfGuests.toString()),
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null && parsed > 0) {
                      numberOfGuests = parsed;
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dietaryController,
                  decoration: const InputDecoration(
                    labelText: 'Dietary Restrictions (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a name')),
                  );
                  return;
                }

                try {
                  final guest = Guest(
                    weddingId: widget.wedding.id!,
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
                    email: emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
                    relationship: relationship,
                    rsvpStatus: rsvpStatus,
                    numberOfGuests: numberOfGuests,
                    dietaryRestrictions: dietaryController.text.trim().isNotEmpty ? dietaryController.text.trim() : null,
                  );

                  await ApiService.createGuest(guest);
                  Navigator.pop(context);
                  _loadGuests();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Guest added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
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
    String relationship = guest.relationship;
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
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: relationship,
                  decoration: const InputDecoration(
                    labelText: 'Relationship',
                    border: OutlineInputBorder(),
                  ),
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
                  decoration: const InputDecoration(
                    labelText: 'RSVP Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                    DropdownMenuItem(value: 'declined', child: Text('Declined')),
                  ],
                  onChanged: (value) => setDialogState(() => rsvpStatus = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Number of Guests',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: numberOfGuests.toString()),
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null && parsed > 0) {
                      numberOfGuests = parsed;
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dietaryController,
                  decoration: const InputDecoration(
                    labelText: 'Dietary Restrictions (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a name')),
                  );
                  return;
                }

                try {
                  final updatedGuest = Guest(
                    id: guest.id,
                    weddingId: widget.wedding.id!,
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
                    email: emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
                    relationship: relationship,
                    rsvpStatus: rsvpStatus,
                    numberOfGuests: numberOfGuests,
                    dietaryRestrictions: dietaryController.text.trim().isNotEmpty ? dietaryController.text.trim() : null,
                  );

                  await ApiService.updateGuest(guest.id!, updatedGuest);
                  Navigator.pop(context);
                  _loadGuests();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Guest updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
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
        await ApiService.deleteGuest(guest.id!);
        _loadGuests();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Guest deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}