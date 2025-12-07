import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wedding.dart';
import '../models/budget.dart';
import '../services/api_service.dart';

class BudgetScreen extends StatefulWidget {
  final Wedding wedding;

  const BudgetScreen({Key? key, required this.wedding}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  List<Budget> _budgetItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBudgetItems();
  }

  Future<void> _loadBudgetItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await ApiService.getBudgetItems(widget.wedding.id!);
      setState(() {
        _budgetItems = items;
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

  double _getTotalEstimated() => _budgetItems.fold(0, (sum, item) => sum + item.estimatedCost);
  
  double _getTotalActual() => _budgetItems.fold(0, (sum, item) => sum + (item.actualCost ?? 0));

  @override
  Widget build(BuildContext context) {
    final totalEstimated = _getTotalEstimated();
    final totalActual = _getTotalActual();
    final remaining = widget.wedding.budget - totalActual;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                _buildSummaryCard('Total Budget', widget.wedding.budget, Colors.blue),
                const SizedBox(height: 8),
                _buildSummaryCard('Estimated', totalEstimated, Colors.orange),
                const SizedBox(height: 8),
                _buildSummaryCard('Actual Spent', totalActual, Colors.red),
                const SizedBox(height: 8),
                _buildSummaryCard('Remaining', remaining, remaining >= 0 ? Colors.green : Colors.red),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _budgetItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('No budget items yet', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadBudgetItems,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _budgetItems.length,
                          itemBuilder: (context, index) => _buildBudgetCard(_budgetItems[index]),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBudgetDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildSummaryCard(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            'TZS ${amount.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(Budget item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.category.toUpperCase(), style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text('Est: TZS ${item.estimatedCost.toStringAsFixed(0)}'),
            if (item.actualCost != null)
              Text('Act: TZS ${item.actualCost!.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showEditBudgetDialog(item),
      ),
    );
  }

  void _showAddBudgetDialog() => _showBudgetDialog(null);

  void _showEditBudgetDialog(Budget item) => _showBudgetDialog(item);

  void _showBudgetDialog(Budget? item) {
    final isEdit = item != null;
    final nameController = TextEditingController(text: item?.itemName ?? '');
    final estimatedController = TextEditingController(
      text: item?.estimatedCost.toStringAsFixed(0) ?? '',
    );
    final actualController = TextEditingController(
      text: item?.actualCost?.toStringAsFixed(0) ?? '',
    );
    final notesController = TextEditingController(text: item?.notes ?? '');
    String category = item?.category ?? 'venue';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Budget Item' : 'Add Budget Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'venue', child: Text('Venue')),
                    DropdownMenuItem(value: 'catering', child: Text('Catering')),
                    DropdownMenuItem(value: 'decoration', child: Text('Decoration')),
                    DropdownMenuItem(value: 'photography', child: Text('Photography')),
                    DropdownMenuItem(value: 'music', child: Text('Music')),
                    DropdownMenuItem(value: 'transportation', child: Text('Transportation')),
                    DropdownMenuItem(value: 'accommodation', child: Text('Accommodation')),
                    DropdownMenuItem(value: 'attire', child: Text('Attire')),
                    DropdownMenuItem(value: 'invitation', child: Text('Invitation')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) => setDialogState(() => category = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Item Name *', border: OutlineInputBorder()),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: estimatedController,
                  decoration: const InputDecoration(labelText: 'Estimated Cost (TZS) *', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: actualController,
                  decoration: const InputDecoration(labelText: 'Actual Cost (TZS)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                if (nameController.text.trim().isEmpty || estimatedController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill required fields')),
                  );
                  return;
                }

                try {
                  final budgetData = Budget(
                    id: item?.id,
                    weddingId: widget.wedding.id!,
                    category: category,
                    itemName: nameController.text.trim(),
                    estimatedCost: double.parse(estimatedController.text),
                    actualCost: actualController.text.isNotEmpty ? double.parse(actualController.text) : null,
                    notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
                  );

                  await ApiService.createBudgetItem(budgetData);
                  Navigator.pop(context);
                  _loadBudgetItems();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEdit ? 'Budget updated' : 'Budget item added'),
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