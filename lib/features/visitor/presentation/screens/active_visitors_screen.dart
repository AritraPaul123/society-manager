import 'package:flutter/material.dart';
import 'package:society_man/core/models/auth_models.dart';
import 'package:society_man/core/services/api_service.dart';
import 'package:intl/intl.dart';

class ActiveVisitorsScreen extends StatefulWidget {
  const ActiveVisitorsScreen({super.key});

  @override
  State<ActiveVisitorsScreen> createState() => _ActiveVisitorsScreenState();
}

class _ActiveVisitorsScreenState extends State<ActiveVisitorsScreen> {
  List<VisitorEntry> _activeVisitors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActiveVisitors();
  }

  Future<void> _loadActiveVisitors() async {
    setState(() => _isLoading = true);
    try {
      final entries = await ApiService().getActiveVisitors();
      setState(() {
        _activeVisitors = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading visitors: $e')));
      }
    }
  }

  Future<void> _handleCheckout(String entryId) async {
    final success = await ApiService().updateVisitorExit(entryId);
    if (success) {
      _loadActiveVisitors();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visitor marked out successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to mark out visitor')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        title: const Text(
          'Active Visitors',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activeVisitors.isEmpty
          ? _buildEmptyState()
          : _buildVisitorList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No active visitors',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitorList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activeVisitors.length,
      itemBuilder: (context, index) {
        final visitor = _activeVisitors[index];
        return _buildVisitorCard(visitor);
      },
    );
  }

  Widget _buildVisitorCard(VisitorEntry visitor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8063FC).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Color(0xFF8063FC)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visitor.visitorName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        visitor.purpose,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'In Society',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Entry Time',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      DateFormat('hh:mm a').format(visitor.entryTime),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _handleCheckout(visitor.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8063FC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Mark Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
