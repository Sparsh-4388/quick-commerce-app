import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'order_tracking_screen.dart';

class OrdersScreen extends StatefulWidget {
  final String userId;
  final String token;
  const OrdersScreen({required this.userId, required this.token});

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> _orders = [];
  bool _loading         = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _loading = true);
    final orders = await ApiService.getOrders(widget.userId, widget.token);
    if (!mounted) return;
    setState(() {
      _orders  = orders;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Orders',
          style: TextStyle(
            color: Color(0xFF1A1A1A), fontWeight: FontWeight.w700)),
      ),
      body: _loading
        ? const Center(
            child: CircularProgressIndicator(color: Color(0xFFfb542b)))
        : _orders.isEmpty
          ? _emptyOrders()
          : RefreshIndicator(
              color: const Color(0xFFfb542b),
              onRefresh: _loadOrders,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) => _OrderCard(
                  order: _orders[i],
                  token: widget.token,
                ),
              ),
            ),
    );
  }

  Widget _emptyOrders() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.receipt_long_outlined,
          size: 80, color: Colors.orange.shade200),
        const SizedBox(height: 16),
        const Text('No orders yet',
          style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600,
            color: Colors.grey)),
        const SizedBox(height: 8),
        const Text('Place your first order to see it here',
          style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFfb542b),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Browse Products',
            style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

// ─── Order Card ───────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final String token;
  const _OrderCard({required this.order, required this.token});

  @override
  Widget build(BuildContext context) {
    final orderId   = order['order_id']?.toString() ??
                      order['_id']?.toString() ?? '';
    final total     = order['total_amount'] ?? order['total'] ?? 0;
    final createdAt = order['created_at']?.toString() ?? '';
    final items     = order['items'] as List<dynamic>? ?? [];

    // Format date nicely if possible
    String dateStr = '';
    try {
      final dt = DateTime.parse(createdAt);
      dateStr = '${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      dateStr = createdAt;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.08),
            blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${orderId.length > 8 ? orderId.substring(orderId.length - 8) : orderId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14, color: Color(0xFF1A1A1A)),
                ),
                Text('₹$total',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16, color: Color(0xFFfb542b))),
              ],
            ),

            if (dateStr.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(dateStr,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],

            // Items summary
            if (items.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              ...items.take(3).map((item) {
                final name = item['name'] ?? item['product_id'] ?? 'Product';
                final qty  = item['quantity'] ?? 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('$name  ×$qty',
                        style: const TextStyle(
                          fontSize: 13, color: Color(0xFF555555))),
                    ],
                  ),
                );
              }),
              if (items.length > 3)
                Text('+${items.length - 3} more items',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],

            const SizedBox(height: 12),

            // Track button
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFfb542b),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.local_shipping_outlined,
                  color: Colors.white, size: 16),
                label: const Text('Track Order',
                  style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
                onPressed: () => Navigator.push(context,
                  MaterialPageRoute(
                    builder: (_) => OrderTrackingScreen(
                      orderId: orderId, token: token))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}