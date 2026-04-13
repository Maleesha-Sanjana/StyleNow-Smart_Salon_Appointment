import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_sub_page_helpers.dart';
import '../../theme/app_theme.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('My Orders', style: TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: Colors.white54,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Delivered'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OrderList(uid: uid, filter: 'all'),
          _OrderList(uid: uid, filter: 'active'),
          _OrderList(uid: uid, filter: 'delivered'),
          _OrderList(uid: uid, filter: 'cancelled'),
        ],
      ),
    );
  }
}

// ── Order List ─────────────────────────────────────────────────────────────

class _OrderList extends StatelessWidget {
  final String uid;
  final String filter;

  const _OrderList({required this.uid, required this.filter});

  List<String>? get _statuses {
    switch (filter) {
      case 'active':
        return ['processing', 'confirmed', 'shipped', 'pending'];
      case 'delivered':
        return ['delivered', 'completed'];
      case 'cancelled':
        return ['cancelled'];
      default:
        return null; // all
    }
  }

  Query _buildQuery() {
    Query q = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: uid);
    if (_statuses != null) q = q.where('status', whereIn: _statuses);
    return q;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _buildQuery().orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }
        if (snapshot.hasError) {
          // Fallback without orderBy
          return _FallbackOrderList(query: _buildQuery(), filter: filter);
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return _EmptyOrders(filter: filter);
        return _buildList(context, docs);
      },
    );
  }

  Widget _buildList(BuildContext context, List<QueryDocumentSnapshot> docs) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: docs.length,
      itemBuilder: (context, i) => _OrderCard(doc: docs[i]),
    );
  }
}

class _FallbackOrderList extends StatelessWidget {
  final Query query;
  final String filter;
  const _FallbackOrderList({required this.query, required this.filter});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return _EmptyOrders(filter: filter);
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: docs.length,
          itemBuilder: (context, i) => _OrderCard(doc: docs[i]),
        );
      },
    );
  }
}

// ── Order Card ─────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  const _OrderCard({required this.doc});

  Map<String, dynamic> get data => doc.data() as Map<String, dynamic>;

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'delivered':
      case 'completed':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'processing':
      case 'confirmed':
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String s) {
    switch (s.toLowerCase()) {
      case 'delivered':
      case 'completed':
        return Icons.check_circle_outline;
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'processing':
      case 'confirmed':
        return Icons.inventory_2_outlined;
      case 'pending':
        return Icons.hourglass_top_outlined;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  Future<void> _cancelOrder(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cancel Order',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to cancel this order?'),
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
      await FirebaseFirestore.instance.collection('orders').doc(doc.id).update({
        'status': 'cancelled',
      });
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Order cancelled')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productName = (data['productName'] ?? 'Product').toString();
    final brand = (data['brand'] ?? '').toString();
    final date = (data['date'] ?? '').toString();
    final total = (data['total'] as num?)?.toDouble() ?? 0.0;
    final status = (data['status'] ?? 'pending').toString();
    final quantity = (data['quantity'] as num?)?.toInt() ?? 1;
    final emoji = (data['emoji'] ?? '🛍️').toString();
    final imageUrl = (data['imageUrl'] ?? '').toString();
    final isActive = [
      'processing',
      'confirmed',
      'shipped',
      'pending',
    ].contains(status.toLowerCase());

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _OrderDetailSheet(doc: doc),
      ),
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
            // Status bar
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
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image / emoji
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 64,
                            height: 64,
                            color: AppColors.primary.withValues(alpha: 0.08),
                            child: Center(
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 30),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (brand.isNotEmpty)
                          Text(
                            brand,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              _statusIcon(status),
                              size: 13,
                              color: _statusColor(status),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _capitalize(status),
                              style: TextStyle(
                                fontSize: 12,
                                color: _statusColor(status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Qty: $quantity',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (date.isNotEmpty)
                              Text(
                                date,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'LKR ${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Tracking stepper for active orders
            if (isActive) _TrackingBar(status: status),
            // Action row
            if (isActive || status.toLowerCase() == 'delivered') ...[
              const Divider(height: 1, indent: 14, endIndent: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    if (isActive)
                      TextButton.icon(
                        onPressed: () => _cancelOrder(context),
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        label: const Text('Cancel'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => _OrderDetailSheet(doc: doc),
                      ),
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: const Text('Details'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ── Tracking Progress Bar ──────────────────────────────────────────────────

class _TrackingBar extends StatelessWidget {
  final String status;
  const _TrackingBar({required this.status});

  static const _steps = ['pending', 'confirmed', 'processing', 'shipped'];

  int get _currentStep {
    final idx = _steps.indexOf(status.toLowerCase());
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 16),
          Row(
            children: List.generate(_steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                // Connector line
                final stepIdx = i ~/ 2;
                final done = stepIdx < _currentStep;
                return Expanded(
                  child: Container(
                    height: 2,
                    color: done ? AppColors.accent : Colors.grey.shade300,
                  ),
                );
              }
              final stepIdx = i ~/ 2;
              final done = stepIdx <= _currentStep;
              final labels = ['Placed', 'Confirmed', 'Packing', 'Shipped'];
              return Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: done ? AppColors.accent : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      done ? Icons.check : Icons.circle,
                      size: done ? 13 : 6,
                      color: done ? AppColors.primary : Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[stepIdx],
                    style: TextStyle(
                      fontSize: 9,
                      color: done ? AppColors.accent : Colors.grey,
                      fontWeight: done ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Order Detail Sheet ─────────────────────────────────────────────────────

class _OrderDetailSheet extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  const _OrderDetailSheet({required this.doc});

  Map<String, dynamic> get data => doc.data() as Map<String, dynamic>;

  @override
  Widget build(BuildContext context) {
    final productName = (data['productName'] ?? 'Product').toString();
    final brand = (data['brand'] ?? '').toString();
    final date = (data['date'] ?? '').toString();
    final total = (data['total'] as num?)?.toDouble() ?? 0.0;
    final status = (data['status'] ?? '').toString();
    final quantity = (data['quantity'] as num?)?.toInt() ?? 1;
    final emoji = (data['emoji'] ?? '🛍️').toString();
    final imageUrl = (data['imageUrl'] ?? '').toString();
    final address = (data['deliveryAddress'] ?? '').toString();
    final paymentMethod = (data['paymentMethod'] ?? '').toString();
    final trackingNo = (data['trackingNumber'] ?? '').toString();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SingleChildScrollView(
        child: Column(
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
                  'Order Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                StatusChip(status: status),
              ],
            ),
            const SizedBox(height: 16),

            // Product row
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 56,
                          height: 56,
                          color: AppColors.primary.withValues(alpha: 0.08),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 26),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (brand.isNotEmpty)
                        Text(
                          brand,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            _row(Icons.confirmation_number_outlined, 'Order ID', doc.id),
            _row(Icons.calendar_today_outlined, 'Date', date),
            _row(Icons.shopping_cart_outlined, 'Quantity', '$quantity'),
            _row(
              Icons.payments_outlined,
              'Total',
              'LKR ${total.toStringAsFixed(2)}',
            ),
            if (paymentMethod.isNotEmpty)
              _row(Icons.credit_card_outlined, 'Payment', paymentMethod),
            if (address.isNotEmpty)
              _row(Icons.location_on_outlined, 'Delivery', address),
            if (trackingNo.isNotEmpty)
              _row(Icons.local_shipping_outlined, 'Tracking', trackingNo),

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
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.accent),
          const SizedBox(width: 10),
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────

class _EmptyOrders extends StatelessWidget {
  final String filter;
  const _EmptyOrders({required this.filter});

  @override
  Widget build(BuildContext context) {
    final messages = {
      'all': ('No orders yet', 'Your orders will appear here'),
      'active': ('No active orders', 'Orders being processed will show here'),
      'delivered': ('No delivered orders', 'Completed deliveries appear here'),
      'cancelled': ('No cancelled orders', 'Cancelled orders appear here'),
    };
    final icons = {
      'all': Icons.shopping_bag_outlined,
      'active': Icons.inventory_2_outlined,
      'delivered': Icons.check_circle_outline,
      'cancelled': Icons.cancel_outlined,
    };

    final msg = messages[filter] ?? ('No orders', '');
    final icon = icons[filter] ?? Icons.shopping_bag_outlined;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 72, color: Colors.grey.shade300),
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
