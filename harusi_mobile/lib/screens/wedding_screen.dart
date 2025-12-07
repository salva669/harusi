import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wedding.dart';
import '../services/api_service.dart';

class CreateWeddingScreen extends StatefulWidget {
  final int userId;

  const CreateWeddingScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<CreateWeddingScreen> createState() => _CreateWeddingScreenState();
}

class _CreateWeddingScreenState extends State<CreateWeddingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brideNameController = TextEditingController();
  final _groomNameController = TextEditingController();
  final _venueController = TextEditingController();
  final _budgetController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _selectedDate;
  String _selectedStatus = 'planning';
  bool _isLoading = false;

  final List<Map<String, String>> _statusOptions = [
    {'value': 'planning', 'label': 'Planning'},
    {'value': 'in_progress', 'label': 'In Progress'},
    {'value': 'completed', 'label': 'Completed'},
    {'value': 'cancelled', 'label': 'Cancelled'},
  ];

  @override
  void dispose() {
    _brideNameController.dispose();
    _groomNameController.dispose();
    _venueController.dispose();
    _budgetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)), // 2 years
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _createWedding() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a wedding date'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final wedding = Wedding(
        userId: widget.userId,
        brideName: _brideNameController.text.trim(),
        groomName: _groomNameController.text.trim(),
        weddingDate: _selectedDate!,
        venue: _venueController.text.trim(),
        budget: double.parse(_budgetController.text.replaceAll(',', '')),
        status: _selectedStatus,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      );

      final createdWedding = await ApiService.createWedding(wedding);

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wedding created successfully! 🎉'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back with success result
        Navigator.pop(context, createdWedding);
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Wedding'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 64,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Plan Your Dream Wedding',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Let\'s start with the basics',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Section
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Couple Names Section
                        const Text(
                          'Couple Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Bride Name
                        TextFormField(
                          controller: _brideNameController,
                          decoration: InputDecoration(
                            labelText: 'Bride\'s Name',
                            hintText: 'Enter bride\'s full name',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter bride\'s name';
                            }
                            if (value.trim().length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Groom Name
                        TextFormField(
                          controller: _groomNameController,
                          decoration: InputDecoration(
                            labelText: 'Groom\'s Name',
                            hintText: 'Enter groom\'s full name',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter groom\'s name';
                            }
                            if (value.trim().length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // Wedding Details Section
                        const Text(
                          'Wedding Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Wedding Date
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedDate == null
                                    ? Colors.grey.shade400
                                    : Theme.of(context).primaryColor,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: _selectedDate == null
                                      ? Colors.grey.shade600
                                      : Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedDate == null
                                        ? 'Select Wedding Date'
                                        : _formatDate(_selectedDate!),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _selectedDate == null
                                          ? Colors.grey.shade600
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Venue
                        TextFormField(
                          controller: _venueController,
                          decoration: InputDecoration(
                            labelText: 'Venue',
                            hintText: 'e.g., Serena Hotel, Dar es Salaam',
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          textCapitalization: TextCapitalization.words,
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter wedding venue';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Budget
                        TextFormField(
                          controller: _budgetController,
                          decoration: InputDecoration(
                            labelText: 'Budget (TZS)',
                            hintText: 'e.g., 25000000',
                            prefixIcon: const Icon(Icons.attach_money),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            helperText: 'Enter amount in Tanzanian Shillings',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter budget';
                            }
                            final budget = double.tryParse(value.replaceAll(',', ''));
                            if (budget == null || budget <= 0) {
                              return 'Please enter a valid budget amount';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Status
                        DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Wedding Status',
                            prefixIcon: const Icon(Icons.info_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: _statusOptions.map((status) {
                            return DropdownMenuItem<String>(
                              value: status['value'],
                              child: Text(status['label']!),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedStatus = value;
                              });
                            }
                          },
                        ),

                        const SizedBox(height: 32),

                        // Description Section
                        const Text(
                          'Additional Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description (Optional)',
                            hintText: 'Add any special notes or details about your wedding...',
                            prefixIcon: const Icon(Icons.notes),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                        ),

                        const SizedBox(height: 32),

                        // Create Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _createWedding,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Create Wedding',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),

                        const SizedBox(height: 16),

                        // Cancel Button
                        OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Creating your wedding...',
                          style: TextStyle(fontSize: 16),
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