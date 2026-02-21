import 'package:flutter/material.dart';
import 'order_tracking_screen.dart';
import 'home_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;
  final String userId;
  final String token;
  final Map<String, dynamic> orderData;

  const OrderConfirmationScreen({
    required this.orderId,
    required this.userId,
    required this.token,
    required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    final total = orderData['total'] ?? orderData['order_total'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Success animation area
              Container(
                width: 120, height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFF0C831F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 64,
                ),
              ),

              const SizedBox(height: 28),

              const Text('Order Placed!',
                style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A))),

              const SizedBox(height: 8),

              const Text(
                'Your order has been placed successfully.\nWe\'ll deliver it in 10 minutes!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.5),
              ),

              const SizedBox(height: 36),

              // Order details card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _detailRow('Order ID',
                      orderId.length > 8
                        ? '...${orderId.substring(orderId.length - 8)}'
                        : orderId),
                    if (total != null) ...[
                      const SizedBox(height: 10),
                      _detailRow('Total', '₹$total'),
                    ],
                    const SizedBox(height: 10),
                    _detailRow('Status', 'PLACED'),
                    const SizedBox(height: 10),
                    _detailRow('Estimated Delivery', '10 minutes'),
                  ],
                ),
              ),

              const Spacer(),

              // Track order button
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C831F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(
                      builder: (_) => OrderTrackingScreen(
                        orderId: orderId,
                        token: token,
                      ))),
                  child: const Text('Track Order',
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: Colors.white)),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity, height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0C831F)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomeScreen(
                        userId: userId, token: token)),
                    (_) => false,
                  ),
                  child: const Text('Continue Shopping',
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600,
                      color: Color(0xFF0C831F))),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label,
        style: const TextStyle(color: Colors.grey, fontSize: 14)),
      Text(value,
        style: const TextStyle(
          fontWeight: FontWeight.w600, fontSize: 14,
          color: Color(0xFF1A1A1A))),
    ],
  );
}