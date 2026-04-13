import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_sub_page_helpers.dart';
import '../../theme/app_theme.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('My Bookings', style: TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BookingList(uid: uid, filter: 'upcoming'),
          _BookingList(uid: uid, filter: 'completed'),
          _BookingList(uid: uid, filter: 'cancelled'),
        ],
      ),
    );
  }
}

// ── Booking List per Tab ───────────────────────────────────────────────────

class _BookingList extends StatelessWidget {
  final String uid;
  final String filter; // 'upcoming' | 'completed' | 'cancelled'

  const _BookingList({required this.uid, required this.filter});

  List<String> get _statuses {
    switch (filter) {
      case 'upcoming':
        return ['confirmed', 'processing', 'pending'];
      case 'completed':
        return ['completed'];
      case 'cancelled':
        return ['cancelled'];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: uid)
          .where('status', whereIn: _statuses)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }
        if (snapshot.hasError) {
          // Fallback: query without orderBy in case index isn't ready
          return _FallbackBookingList(uid: uid, statuses: _statuses);
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return _EmptyState(filter: filter);

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: docs.length,
          itemBuilder: (context, i) =>
              _BookingCard(doc: docs[i], filter: filter),
        );
      },
    );
  }
}

// Fallback without orderBy (no composite index needed)
class _FallbackBookingList extends StatelessWidget {
  final String uid;
  final List<String> statuses;

  const _FallbackBookingList({required this.uid, required this.statuses});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: uid)
          .where('status', whereIn: statuses)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _EmptyState(
            filter: statuses.contains('confirmed')
                ? 'upcoming'
                : statuses.first,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: docs.length,
          itemBuilder: (context, i) => _BookingCard(
            doc: docs[i],
            filter: statuses.contains('confirmed')
                ? 'upcoming'
                : statuses.first,
          ),
        );
      },
    );
  }
}

// ── Booking Card ───────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final String filter;

  const _BookingCard({required this.doc, required this.filter});

  Map<String, dynamic> get data => doc.data() as Map<String, dynamic>;

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingDetailSheet(doc: doc),
    );
  }

  Future<void> _cancelBooking(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cancel Booking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(doc.id)
          .update({'status': 'cancelled'});
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Booking cancelled')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = (data['status'] ?? '').toString();
    final salonName = (data['salonName'] ?? 'Salon').toString();
    final serviceName = (data['serviceName'] ?? '').toString();
    final date = (data['date'] ?? '').toString();
    final time = (data['time'] ?? '').toString();
    final price = data['price'];

    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top accent bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: _statusColor(status),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Salon name + status chip
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          salonName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      StatusChip(status: status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Service name
                  Text(
                    serviceName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Date / Time / Price row
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(date, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 14),
                      const Icon(
                        Icons.access_time_outlined,
                        size: 14,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(time, style: const TextStyle(fontSize: 13)),
                      if (price != null) ...[
                        const Spacer(),
                        Text(
                          'LKR ${price.toString()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Cancel button for upcoming bookings
                  if (filter == 'upcoming') ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () => _showDetails(context),
                          icon: const Icon(Icons.info_outline, size: 16),
                          label: const Text('Details'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.accent,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _cancelBooking(context),
                          icon: const Icon(Icons.cancel_outlined, size: 16),
                          label: const Text('Cancel'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'processing':
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// ── Booking Detail Bottom Sheet ────────────────────────────────────────────

class _BookingDetailSheet extends StatelessWidget {
  final QueryDocumentSnapshot doc;

  const _BookingDetailSheet({required this.doc});

  Map<String, dynamic> get data => doc.data() as Map<String, dynamic>;

  @override
  Widget build(BuildContext context) {
    final status = (data['status'] ?? '').toString();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'Booking Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              StatusChip(status: status),
            ],
          ),
          const SizedBox(height: 20),
          _detailRow(
            Icons.store_outlined,
            'Salon',
            (data['salonName'] ?? '').toString(),
          ),
          _detailRow(
            Icons.content_cut_outlined,
            'Service',
            (data['serviceName'] ?? '').toString(),
          ),
          _detailRow(
            Icons.calendar_today_outlined,
            'Date',
            (data['date'] ?? '').toString(),
          ),
          _detailRow(
            Icons.access_time_outlined,
            'Time',
            (data['time'] ?? '').toString(),
          ),
          if (data['staffName'] != null)
            _detailRow(
              Icons.person_outline,
              'Staff',
              data['staffName'].toString(),
            ),
          if (data['price'] != null)
            _detailRow(
              Icons.payments_outlined,
              'Price',
              'LKR ${data['price']}',
            ),
          if (data['notes'] != null && data['notes'].toString().isNotEmpty)
            _detailRow(Icons.notes_outlined, 'Notes', data['notes'].toString()),
          const SizedBox(height: 8),
          // Booking ID
          Text(
            'Booking ID: ${doc.id}',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(width: 12),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final messages = {
      'upcoming': (
        'No upcoming bookings',
        'Book a salon service to get started',
      ),
      'completed': (
        'No completed bookings',
        'Your past bookings will appear here',
      ),
      'cancelled': (
        'No cancelled bookings',
        'Cancelled bookings will appear here',
      ),
    };
    final icons = {
      'upcoming': Icons.calendar_today_outlined,
      'completed': Icons.check_circle_outline,
      'cancelled': Icons.cancel_outlined,
    };

    final msg = messages[filter] ?? ('No bookings', '');
    final icon = icons[filter] ?? Icons.calendar_today_outlined;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            msg.$1,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            msg.$2,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
