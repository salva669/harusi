import 'package:flutter/material.dart';
import '../models/wedding.dart';
import '../services/api_service.dart';
import 'create_wedding_screen.dart';
import 'guests_screen.dart';
import 'tasks_screen.dart';
import 'budget_screen.dart';
import 'vendors_screen.dart';
import 'timeline_screen.dart';
import 'wedding_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  
  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Wedding? _currentWedding;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWedding();
  }

  Future<void> _loadWedding() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final weddings = await ApiService.getWeddings();
      if (weddings.isNotEmpty) {
        setState(() {
          _currentWedding = weddings.first;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ✅ NEW: Helper method for safe navigation to Analytics Dashboard
  void _navigateToAnalyticsDashboard() {
    // Check if wedding exists and has a valid ID
    if (_currentWedding == null || _currentWedding!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a wedding first'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Navigate to dashboard
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WeddingDashboardScreen(
          weddingId: _currentWedding!.id!, // ✅ Safe to use double bang here
        ),
      ),
    );
  }

  int _daysUntilWedding() {
    if (_currentWedding == null) return 0;
    return _currentWedding!.weddingDate.difference(DateTime.now()).inDays;
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'planning':
        return 'Planning';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'planning':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harusi Mobile'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications - Coming Soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings - Coming Soon')),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _currentWedding == null
                  ? _buildNoWeddingState()
                  : _buildDashboard(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading wedding',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadWedding,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoWeddingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Wedding Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first wedding to start planning',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateWeddingScreen(userId: widget.userId),
                  ),
                );
                
                if (result != null) {
                  _loadWedding();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Wedding'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    final daysLeft = _daysUntilWedding();

    return RefreshIndicator(
      onRefresh: _loadWedding,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_currentWedding!.brideName} & ${_currentWedding!.groomName}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.white70, size: 16),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _currentWedding!.venue,
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(_currentWedding!.weddingDate),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // ✅ FIXED: Analytics Quick Access Button
                      IconButton(
                        onPressed: _navigateToAnalyticsDashboard,
                        icon: const Icon(Icons.analytics, color: Colors.white),
                        iconSize: 32,
                        tooltip: 'View Analytics',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(_currentWedding!.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusLabel(_currentWedding!.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Countdown Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink[50]!, Colors.purple[50]!],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: Theme.of(context).primaryColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$daysLeft days to go!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          daysLeft > 7 ? '${(daysLeft / 7).floor()} weeks remaining' : 'The big day is near!',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Quick Actions Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      // ✅ FIXED: Analytics card
                      _buildQuickActionCard(
                        'Analytics',
                        Icons.analytics,
                        Colors.purple,
                        _navigateToAnalyticsDashboard,
                      ),
                      _buildQuickActionCard(
                        'Guests',
                        Icons.people,
                        Colors.blue,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GuestsScreen(wedding: _currentWedding!),
                            ),
                          );
                        },
                      ),
                      _buildQuickActionCard(
                        'Tasks',
                        Icons.checklist,
                        Colors.orange,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TasksScreen(wedding: _currentWedding!),
                            ),
                          );
                        },
                      ),
                      _buildQuickActionCard(
                        'Budget',
                        Icons.account_balance_wallet,
                        Colors.green,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BudgetScreen(wedding: _currentWedding!),
                            ),
                          );
                        },
                      ),
                      _buildQuickActionCard(
                        'Vendors',
                        Icons.business,
                        Colors.teal,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VendorsScreen(wedding: _currentWedding!),
                            ),
                          );
                        },
                      ),
                      _buildQuickActionCard(
                        'Timeline',
                        Icons.event_note,
                        Colors.indigo,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TimelineScreen(wedding: _currentWedding!),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink[400]!, Colors.purple[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.favorite, color: Colors.pink, size: 30),
                ),
                const SizedBox(height: 12),
                Text(
                  _currentWedding != null
                      ? '${_currentWedding!.brideName} & ${_currentWedding!.groomName}'
                      : 'Wedding Planner',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _currentWedding != null
                      ? 'Wedding: ${_formatDate(_currentWedding!.weddingDate)}'
                      : 'Plan your special day',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Home - Default landing page with overview
          ListTile(
            leading: const Icon(Icons.home, color: Colors.pink),
            title: const Text('Home'),
            subtitle: const Text('Overview & Quick Actions'),
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          
          const Divider(),
          
          // ✅ FIXED: Analytics Dashboard
          ListTile(
            leading: const Icon(Icons.analytics, color: Colors.purple),
            title: const Text('Analytics Dashboard'),
            subtitle: const Text('Detailed insights & reports'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            enabled: _currentWedding != null && _currentWedding!.id != null,
            onTap: () {
              Navigator.pop(context);
              _navigateToAnalyticsDashboard();
            },
          ),
          
          const Divider(),
          
          // Other menu items
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Guests'),
            enabled: _currentWedding != null,
            onTap: () {
              Navigator.pop(context);
              if (_currentWedding != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GuestsScreen(wedding: _currentWedding!),
                  ),
                );
              }
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Budget'),
            enabled: _currentWedding != null,
            onTap: () {
              Navigator.pop(context);
              if (_currentWedding != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BudgetScreen(wedding: _currentWedding!),
                  ),
                );
              }
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Tasks'),
            enabled: _currentWedding != null,
            onTap: () {
              Navigator.pop(context);
              if (_currentWedding != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TasksScreen(wedding: _currentWedding!),
                  ),
                );
              }
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Vendors'),
            enabled: _currentWedding != null,
            onTap: () {
              Navigator.pop(context);
              if (_currentWedding != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VendorsScreen(wedding: _currentWedding!),
                  ),
                );
              }
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.timeline),
            title: const Text('Timeline'),
            enabled: _currentWedding != null,
            onTap: () {
              Navigator.pop(context);
              if (_currentWedding != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TimelineScreen(wedding: _currentWedding!),
                  ),
                );
              }
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Create New Wedding'),
            onTap: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateWeddingScreen(userId: widget.userId),
                ),
              );
              
              if (result != null) {
                _loadWedding();
              }
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings - Coming Soon')),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & Support - Coming Soon')),
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              
              if (confirm == true) {
                await ApiService.logout();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}