import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wedding.dart';
import '../models/vendor.dart';
import '../services/api_service.dart';

class VendorsScreen extends StatefulWidget {
  final Wedding wedding;

  const VendorsScreen({Key? key, required this.wedding}) : super(key: key);

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  List<Vendor> _vendors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    setState(() => _isLoading = true);
    try {
      final vendors = await ApiService.getVendors(widget.wedding.id!);
      setState(() {
        _vendors = vendors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'booked': return Colors.green;
      case 'negotiating': return Colors.orange;
      case 'inquiry': return Colors.blue;
      case 'rejected': return Colors.red;
      case 'completed': return Colors.purple;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Vendor>>{};
    for (var vendor in _vendors) {
      grouped.putIfAbsent(vendor.vendorType, () => []).add(vendor);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendors'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vendors.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No vendors yet', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadVendors,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _vendors.length,
                    itemBuilder: (context, index) => _buildVendorCard(_vendors[index]),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddVendorDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Vendor'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildVendorCard(Vendor vendor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(vendor.status).withOpacity(0.2),
          child: Icon(Icons.business, color: _getStatusColor(vendor.status)),
        ),
        title: Text(vendor.businessName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vendor.vendorType.toUpperCase(), style: const TextStyle(fontSize: 12)),
            Text(vendor.contactPerson),
            Text(vendor.phone),
            if (vendor.quote != null) Text('Quote: TZS ${vendor.quote!.toStringAsFixed(0)}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(vendor.status),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            vendor.status.toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () => _showVendorDetails(vendor),
      ),
    );
  }

  void _showAddVendorDialog() => _showVendorDialog(null);

  void _showVendorDetails(Vendor vendor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(vendor.businessName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Type', vendor.vendorType),
              _buildDetailRow('Contact', vendor.contactPerson),
              _buildDetailRow('Phone', vendor.phone),
              _buildDetailRow('Email', vendor.email),
              if (vendor.website != null) _buildDetailRow('Website', vendor.website!),
              if (vendor.quote != null) _buildDetailRow('Quote', 'TZS ${vendor.quote!.toStringAsFixed(0)}'),
              if (vendor.depositPaid != null) _buildDetailRow('Deposit', 'TZS ${vendor.depositPaid!.toStringAsFixed(0)}'),
              _buildDetailRow('Status', vendor.status),
              if (vendor.vendorNotes != null) _buildDetailRow('Notes', vendor.vendorNotes!),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showVendorDialog(vendor);
            },
            child: const Text('Edit'),
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
          SizedBox(width: 80, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showVendorDialog(Vendor? vendor) {
    final isEdit = vendor != null;
    final businessController = TextEditingController(text: vendor?.businessName ?? '');
    final contactController = TextEditingController(text: vendor?.contactPerson ?? '');
    final phoneController = TextEditingController(text: vendor?.phone ?? '');
    final emailController = TextEditingController(text: vendor?.email ?? '');
    final websiteController = TextEditingController(text: vendor?.website ?? '');
    final quoteController = TextEditingController(text: vendor?.quote?.toStringAsFixed(0) ?? '');
    final notesController = TextEditingController(text: vendor?.vendorNotes ?? '');
    String vendorType = vendor?.vendorType ?? 'venue';
    String status = vendor?.status ?? 'inquiry';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Vendor' : 'Add Vendor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: vendorType,
                  decoration: const InputDecoration(labelText: 'Vendor Type', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'venue', child: Text('Venue')),
                    DropdownMenuItem(value: 'catering', child: Text('Catering')),
                    DropdownMenuItem(value: 'photography', child: Text('Photography')),
                    DropdownMenuItem(value: 'videography', child: Text('Videography')),
                    DropdownMenuItem(value: 'flowers', child: Text('Flowers & Decoration')),
                    DropdownMenuItem(value: 'music', child: Text('Music & DJ')),
                    DropdownMenuItem(value: 'transportation', child: Text('Transportation')),
                    DropdownMenuItem(value: 'accommodation', child: Text('Accommodation')),
                    DropdownMenuItem(value: 'invitation', child: Text('Invitation & Stationery')),
                    DropdownMenuItem(value: 'makeup', child: Text('Makeup & Hair')),
                    DropdownMenuItem(value: 'wedding_planner', child: Text('Wedding Planner')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) => setDialogState(() => vendorType = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: businessController,
                  decoration: const InputDecoration(labelText: 'Business Name *', border: OutlineInputBorder()),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contactController,
                  decoration: const InputDecoration(labelText: 'Contact Person *', border: OutlineInputBorder()),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone *', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email *', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: websiteController,
                  decoration: const InputDecoration(labelText: 'Website', border: OutlineInputBorder()),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quoteController,
                  decoration: const InputDecoration(labelText: 'Quote (TZS)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'inquiry', child: Text('Inquiry')),
                    DropdownMenuItem(value: 'negotiating', child: Text('Negotiating')),
                    DropdownMenuItem(value: 'booked', child: Text('Booked')),
                    DropdownMenuItem(value: 'completed', child: Text('Completed')),
                    DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                  ],
                  onChanged: (value) => setDialogState(() => status = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (businessController.text.trim().isEmpty ||
                    contactController.text.trim().isEmpty ||
                    phoneController.text.trim().isEmpty ||
                    emailController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill required fields')),
                  );
                  return;
                }

                try {
                  final vendorData = Vendor(
                    id: vendor?.id,
                    weddingId: widget.wedding.id!,
                    vendorType: vendorType,
                    businessName: businessController.text.trim(),
                    contactPerson: contactController.text.trim(),
                    phone: phoneController.text.trim(),
                    email: emailController.text.trim(),
                    website: websiteController.text.trim().isNotEmpty ? websiteController.text.trim() : null,
                    quote: quoteController.text.isNotEmpty ? double.parse(quoteController.text) : null,
                    status: status,
                    vendorNotes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
                  );

                  await ApiService.createVendor(widget.wedding.id!, vendorData);
                  Navigator.pop(context);
                  _loadVendors();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEdit ? 'Vendor updated' : 'Vendor added'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
                  );
                }
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }
}