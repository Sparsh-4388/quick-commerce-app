import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final String token;
  const OrderTrackingScreen({required this.orderId, required this.token});

  @override
  _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  String _status = 'PLACED';
  bool _loading  = true;
  Timer? _timer;

  // Status flow matching backend
  static const _steps = [
    'PLACED',
    'PACKED',
    'OUT_FOR_DELIVERY',
    'DELIVERED',
  ];

  static const _stepLabels = {
    'PLACED':           'Order Placed',
    'PACKED':           'Order Packed',
    'OUT_FOR_DELIVERY': 'Out for Delivery',
    'DELIVERED':        'Delivered!',
  };

  static const _stepIcons = {
    'PLACED':           Icons.receipt_long_outlined,
    'PACKED':           Icons.inventory_2_outlined,
    'OUT_FOR_DELIVERY': Icons.delivery_dining_outlined,
    'DELIVERED':        Icons.check_circle_outline,
  };

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    // Poll every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchStatus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    final s = await ApiService.getOrderStatus(widget.orderId, widget.token);
    if (!mounted) return;
    setState(() { _status = s; _loading = false; });
  }

  int get _currentStep => _steps.indexOf(_status);

  bool get _isDelivered => _status == 'DELIVERED';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Track Order',
          style: TextStyle(
            color: Color(0xFF1A1A1A), fontWeight: FontWeight.w700)),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF0C831F)))
        : Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_outlined,
                        color: Color(0xFF0C831F), size: 20),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Order ID',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(
                            widget.orderId.length > 12
                              ? '...${widget.orderId.substring(widget.orderId.length - 12)}'
                              : widget.orderId,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isDelivered
                            ? const Color(0xFF0C831F)
                            : const Color(0xFFFFA500),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _status.replaceAll('_', ' '),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                const Text('Delivery Status',
                  style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A))),

                const SizedBox(height: 24),

                // Status tracker
                ..._buildStatusSteps(),

                const Spacer(),

                // Estimated time
                if (!_isDelivered)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C831F).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.timer_outlined,
                          color: Color(0xFF0C831F), size: 20),
                        SizedBox(width: 10),
                        Text('Estimated delivery in 10 minutes',
                          style: TextStyle(
                            color: Color(0xFF0C831F),
                            fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C831F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text('Order Delivered! Enjoy your items 🎉',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // Refresh button
                Center(
                  child: TextButton.icon(
                    onPressed: _fetchStatus,
                    icon: const Icon(Icons.refresh,
                      color: Color(0xFF0C831F), size: 18),
                    label: const Text('Refresh Status',
                      style: TextStyle(color: Color(0xFF0C831F))),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  List<Widget> _buildStatusSteps() {
    return List.generate(_steps.length, (i) {
      final step      = _steps[i];
      final label     = _stepLabels[step]!;
      final icon      = _stepIcons[step]!;
      final isDone    = _currentStep >= i && _currentStep != -1;
      final isCurrent = _currentStep == i;
      final isLast    = i == _steps.length - 1;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + Line
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: isDone
                    ? const Color(0xFF0C831F)
                    : Colors.grey.shade200,
                  shape: BoxShape.circle,
                  boxShadow: isCurrent ? [
                    BoxShadow(
                      color: const Color(0xFF0C831F).withOpacity(0.3),
                      blurRadius: 8, spreadRadius: 2),
                  ] : [],
                ),
                child: Icon(icon,
                  color: isDone ? Colors.white : Colors.grey,
                  size: 20),
              ),
              if (!isLast)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 2, height: 40,
                  color: _currentStep > i
                    ? const Color(0xFF0C831F)
                    : Colors.grey.shade200,
                ),
            ],
          ),

          const SizedBox(width: 16),

          // Label
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(label,
              style: TextStyle(
                fontWeight: isCurrent
                  ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
                color: isDone
                  ? const Color(0xFF1A1A1A)
                  : Colors.grey,
              )),
          ),
        ],
      );
    });
  }
}