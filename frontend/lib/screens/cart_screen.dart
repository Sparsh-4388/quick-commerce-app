import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'order_confirmation_screen.dart';

class CartScreen extends StatefulWidget {
  final String userId;
  final String token;
  const CartScreen({required this.userId, required this.token});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> _cartItems = [];
  bool _loading            = true;
  bool _placing            = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => _loading = true);
    final items = await ApiService.getCart(widget.userId, widget.token);
    if (!mounted) return;
    setState(() {
      _cartItems = items;
      _loading   = false;
    });
  }

  double get _total => _cartItems.fold(0.0, (sum, item) {
    final price = (item['price'] ?? item['unit_price'] ?? 0.0) as num;
    final qty   = (item['quantity'] ?? 1) as num;
    return sum + price * qty;
  });

  Future<void> _removeItem(Map<String, dynamic> item) async {
    final productId = item['product_id']?.toString() ?? '';
    await ApiService.removeFromCart(
      widget.userId, widget.token, productId, 1);
    _loadCart();
  }

  Future<void> _placeOrder() async {
    setState(() => _placing = true);
    final res = await ApiService.createOrder(widget.userId, widget.token);
    if (!mounted) return;
    setState(() => _placing = false);

    if (res.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['error'] ?? 'Order failed'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to confirmation
    final orderId = res['order_id']?.toString() ??
                    res['_id']?.toString() ?? '';
    Navigator.pushReplacement(context,
      MaterialPageRoute(
        builder: (_) => OrderConfirmationScreen(
          orderId: orderId,
          userId: widget.userId,
          token: widget.token,
          orderData: res,
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFB347),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Cart',
          style: TextStyle(
            color: Color(0xFFfb542b), fontWeight: FontWeight.w700)),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF0C831F)))
        : _cartItems.isEmpty
          ? _emptyCart()
          : Column(
              children: [
                // Cart items list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadCart,
                    color: const Color(0xFFFFCCBC),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _cartItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) => _CartItemTile(
                        item: _cartItems[i],
                        onRemove: () => _removeItem(_cartItems[i]),
                      ),
                    ),
                  ),
                ),

                // Order summary + button
                Container(
                  color: const Color(0xFFFFD180),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Items',
                            style: TextStyle(color: const Color(0xFFfb542b), fontSize: 14)),
                          Text('${_cartItems.length}',
                            style: const TextStyle(
                              color: const Color(0xFFfb542b), fontWeight: FontWeight.w600, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                            style: TextStyle(
                              color: const Color(0xFFfb542b), fontWeight: FontWeight.w700, fontSize: 16)),
                          Text('₹${_total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 18,
                              color: Color(0xFFfb542b))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8C42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _placing ? null : _placeOrder,
                          child: _placing
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                            : const Text('Place Order',
                                style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _emptyCart() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shopping_cart_outlined,
          size: 80, color: const Color(0xFFFF8C42)),
        const SizedBox(height: 16),
        const Text('Your cart is empty',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
            color: const Color(0xFFFF9F1C))),
        const SizedBox(height: 8),
        const Text('Add items to get started',
          style: TextStyle(color: const Color(0xFFFF9F1C))),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF8C42),
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

// ─── Cart Item Tile ───────────────────────────────────────────────────────────

class _CartItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onRemove;
  const _CartItemTile({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final name  = item['name'] ?? item['product_id'] ?? 'Product';
    final price = (item['price'] ?? item['unit_price'] ?? 0.0) as num;
    final qty   = (item['quantity'] ?? 1) as num;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFc870),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFFECB3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shopping_bag_outlined,
              color: Colors.grey, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14,
                    color: Color(0xFF1A1A1A))),
                const SizedBox(height: 4),
                Text('Qty: $qty',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${(price * qty).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15,
                  color: Color(0xFF0C831F))),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onRemove,
                child: const Text('Remove',
                  style: TextStyle(
                    color: Colors.red, fontSize: 12,
                    fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}