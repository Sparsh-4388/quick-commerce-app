import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final String userId;
  final String token;

  const ProductDetailScreen({
    required this.product,
    required this.userId,
    required this.token,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _adding  = false;

  Future<void> _addToCart() async {
    setState(() => _adding = true);
    final productId = widget.product['product_id']?.toString() ??
                      widget.product['id']?.toString() ?? '';
    final ok = await ApiService.addToCart(
      widget.userId, widget.token, productId, _quantity);
    if (!mounted) return;
    setState(() => _adding = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Added $_quantity item(s) to cart!' : 'Failed to add item'),
      backgroundColor: ok ? const Color(0xFF0C831F) : Colors.red,
      duration: const Duration(seconds: 1),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p         = widget.product;
    final name      = p['name'] ?? 'Product';
    final desc      = p['description'] ?? 'No description available.';
    final price     = p['price']?.toString() ?? '0';
    final category  = p['category'] ?? '';
    final imageUrl  = p['image_url'] as String?;
    final available = p['available'] as bool? ?? true;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFB347),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF1A1A1A)),
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) =>
                CartScreen(userId: widget.userId, token: widget.token))),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 280, width: double.infinity,
                    color: const Color(0xFFF0FFF4),
                    child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(imageUrl, fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.image_not_supported_outlined,
                              color: Colors.grey, size: 60)))
                      : const Center(
                          child: Icon(Icons.image_not_supported_outlined,
                            color: Colors.grey, size: 60)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (category.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD180).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(category,
                              style: const TextStyle(
                                color: Color(0xFFFF9F1C),
                                fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        const SizedBox(height: 12),
                        Text(name, style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w700,
                          color: Color(0xFFfb542b))),
                        const SizedBox(height: 8),
                        Text('₹$price', style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w800,
                          color: Color(0xFFFF9F1C))),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 12),
                        const Text('About this product', style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: Color(0xFFFF9F1C))),
                        const SizedBox(height: 8),
                        Text(desc, style: const TextStyle(
                          fontSize: 14, color: const Color(0xFFFF9F1C), height: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (available)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0D9),
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10, offset: const Offset(0, -4))],
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFFF9F1C)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() { if (_quantity > 1) _quantity--; }),
                          child: Container(width: 36, height: 36,
                            alignment: Alignment.center,
                            child: const Icon(Icons.remove, size: 18,
                              color: Color(0xFFFF9F1C))),
                        ),
                        SizedBox(width: 36,
                          child: Center(child: Text('$_quantity',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)))),
                        GestureDetector(
                          onTap: () => setState(() => _quantity++),
                          child: Container(width: 36, height: 36,
                            alignment: Alignment.center,
                            child: const Icon(Icons.add, size: 18,
                              color: Color(0xFFFF9F1C))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9F1C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _adding ? null : _addToCart,
                        child: _adding
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(
                                color: const Color(0xFFFF9F1C), strokeWidth: 2))
                          : const Text('Add to Cart',
                              style: TextStyle(fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFFFF0D9))),
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
