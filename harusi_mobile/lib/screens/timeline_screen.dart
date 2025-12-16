import 'package:flutter/material.dart';
import '../models/wedding.dart';
import '../models/timeline.dart';
import '../services/api_service.dart';

class TimelineScreen extends StatefulWidget {
  final Wedding wedding;

  const TimelineScreen({Key? key, required this.wedding}) : super(key: key);

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  List<Timeline> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final events = await ApiService.getTimelineEvents(widget.wedding.id!);
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading timeline: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '';
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return time;
    }
  }

  Color _getEventTypeColor(String eventType) {
    switch (eventType) {
      case 'wedding_day':
        return Colors.pink;
      case 'ceremony_rehearsal':
        return Colors.purple;
      case 'invitation':
        return Colors.blue;
      case 'rsvp_deadline':
        return Colors.orange;
      case 'honeymoon':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getEventTypeIcon(String eventType) {
    switch (eventType) {
      case 'wedding_day':
        return Icons.favorite;
      case 'ceremony_rehearsal':
        return Icons.church;
      case 'save_date':
        return Icons.calendar_today;
      case 'invitation':
        return Icons.mail;
      case 'rsvp_deadline':
        return Icons.alarm;
      case 'final_headcount':
        return Icons.people;
      case 'honeymoon':
        return Icons.flight;
      case 'thank_you':
        return Icons.card_giftcard;
      default:
        return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_note, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No timeline events yet',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to add your first event',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadEvents,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _events.length,
                    itemBuilder: (context, index) => _buildTimelineCard(_events[index], index),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEventDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildTimelineCard(Timeline event, int index) {
    final isCompleted = event.isCompleted;
    final isPast = event.date.isBefore(DateTime.now()) && !_isSameDay(event.date, DateTime.now());
    final eventColor = _getEventTypeColor(event.eventType);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showEventDetails(event),
        onLongPress: () => _showEventOptions(event),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline Indicator
              Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? Colors.green.withOpacity(0.2) 
                          : eventColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isCompleted ? Colors.green : eventColor,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isCompleted 
                          ? Icons.check 
                          : _getEventTypeIcon(event.eventType),
                      color: isCompleted ? Colors.green : eventColor,
                      size: 24,
                    ),
                  ),
                  if (index < _events.length - 1)
                    Container(
                      width: 2,
                      height: 40,
                      color: Colors.grey[300],
                      margin: const EdgeInsets.only(top: 8),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Event Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              color: isCompleted ? Colors.grey[600] : Colors.black,
                            ),
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'DONE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: eventColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getEventTypeLabel(event.eventType),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: eventColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(event.date),
                          style: TextStyle(
                            fontSize: 13,
                            color: isPast ? Colors.red : Colors.grey[700],
                            fontWeight: isPast ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (event.time != null && event.time!.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(event.time),
                            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                          ),
                        ],
                      ],
                    ),
                    if (event.location != null && event.location!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (event.description != null && event.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        event.description!,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Checkbox
              Checkbox(
                value: isCompleted,
                onChanged: (value) => _toggleEventCompletion(event, value ?? false),
                activeColor: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getEventTypeLabel(String eventType) {
    switch (eventType) {
      case 'save_date':
        return 'Save the Date';
      case 'invitation':
        return 'Send Invitations';
      case 'rsvp_deadline':
        return 'RSVP Deadline';
      case 'final_headcount':
        return 'Final Headcount';
      case 'ceremony_rehearsal':
        return 'Ceremony Rehearsal';
      case 'wedding_day':
        return 'Wedding Day';
      case 'honeymoon':
        return 'Honeymoon';
      case 'thank_you':
        return 'Thank You Cards';
      default:
        return 'Other';
    }
  }

  void _showEventOptions(Timeline event) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit Event'),
              onTap: () {
                Navigator.pop(context);
                _showEventDialog(event: event);
              },
            ),
            ListTile(
              leading: Icon(
                event.isCompleted ? Icons.remove_done : Icons.check,
                color: Colors.green,
              ),
              title: Text(event.isCompleted ? 'Mark as Pending' : 'Mark as Complete'),
              onTap: () {
                Navigator.pop(context);
                _toggleEventCompletion(event, !event.isCompleted);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Event'),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteEvent(event);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDetails(Timeline event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Type', _getEventTypeLabel(event.eventType)),
              _buildDetailRow('Date', _formatDate(event.date)),
              if (event.time != null && event.time!.isNotEmpty)
                _buildDetailRow('Time', _formatTime(event.time)),
              if (event.location != null && event.location!.isNotEmpty)
                _buildDetailRow('Location', event.location!),
              if (event.description != null && event.description!.isNotEmpty)
                _buildDetailRow('Description', event.description!),
              _buildDetailRow('Status', event.isCompleted ? 'Completed' : 'Pending'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showEventDialog(event: event);
            },
            child: const Text('Edit'),
          ),
          if (!event.isCompleted)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _toggleEventCompletion(event, true);
              },
              child: const Text('Mark Complete'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _toggleEventCompletion(Timeline event, bool isCompleted) async {
    try {
      // Update local state optimistically
      setState(() {
        final index = _events.indexWhere((e) => e.id == event.id);
        if (index != -1) {
          _events[index] = event.copyWith(isCompleted: isCompleted);
        }
      });

      // Call API to toggle (it will flip the current state)
      await ApiService.toggleTimelineEventCompletion(
        widget.wedding.id!,
        event.id!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCompleted ? 'Event marked as complete' : 'Event marked as pending'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Revert local state on error
      setState(() {
        final index = _events.indexWhere((e) => e.id == event.id);
        if (index != -1) {
          _events[index] = event.copyWith(isCompleted: !isCompleted);
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating event: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmDeleteEvent(Timeline event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvent(event);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEvent(Timeline event) async {
    try {
      await ApiService.deleteTimelineEvent(widget.wedding.id!, event.id!);
      
      setState(() {
        _events.removeWhere((e) => e.id == event.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting event: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEventDialog({Timeline? event}) {
    final isEditing = event != null;
    final titleController = TextEditingController(text: event?.title);
    final descriptionController = TextEditingController(text: event?.description);
    final locationController = TextEditingController(text: event?.location);
    String eventType = event?.eventType ?? 'save_date';
    DateTime? selectedDate = event?.date;
    TimeOfDay? selectedTime;
    
    // Parse existing time if available
    if (event?.time != null && event!.time!.isNotEmpty) {
      try {
        final parts = event.time!.split(':');
        selectedTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } catch (e) {
        // Ignore parse error
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Timeline Event' : 'Add Timeline Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: eventType,
                  decoration: const InputDecoration(
                    labelText: 'Event Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'save_date', child: Text('Save the Date')),
                    DropdownMenuItem(value: 'invitation', child: Text('Send Invitations')),
                    DropdownMenuItem(value: 'rsvp_deadline', child: Text('RSVP Deadline')),
                    DropdownMenuItem(value: 'final_headcount', child: Text('Final Headcount')),
                    DropdownMenuItem(value: 'ceremony_rehearsal', child: Text('Ceremony Rehearsal')),
                    DropdownMenuItem(value: 'wedding_day', child: Text('Wedding Day')),
                    DropdownMenuItem(value: 'honeymoon', child: Text('Honeymoon')),
                    DropdownMenuItem(value: 'thank_you', child: Text('Send Thank You Cards')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) => setDialogState(() => eventType = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date *',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      selectedDate != null ? _formatDate(selectedDate!) : 'Select date',
                      style: TextStyle(
                        color: selectedDate != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedTime = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Time (Optional)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    child: Text(
                      selectedTime != null ? selectedTime!.format(context) : 'Select time',
                      style: TextStyle(
                        color: selectedTime != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
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
                if (titleController.text.trim().isEmpty || selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill required fields')),
                  );
                  return;
                }

                try {
                  final timelineData = Timeline(
                    id: event?.id,
                    weddingId: widget.wedding.id!,
                    eventType: eventType,
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim().isNotEmpty
                        ? descriptionController.text.trim()
                        : null,
                    date: selectedDate!,
                    time: selectedTime != null
                        ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00'
                        : null,
                    location: locationController.text.trim().isNotEmpty
                        ? locationController.text.trim()
                        : null,
                    isCompleted: event?.isCompleted ?? false,
                    createdAt: event?.createdAt,
                  );

                  if (isEditing) {
                    await ApiService.updateTimelineEvent(
                      widget.wedding.id!,
                      event.id!,
                      timelineData,
                    );
                  } else {
                    await ApiService.createTimelineEvent(
                      widget.wedding.id!,
                      timelineData,
                    );
                  }

                  Navigator.pop(context);
                  _loadEvents();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEditing 
                          ? 'Event updated successfully' 
                          : 'Event added successfully'),
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
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }
}