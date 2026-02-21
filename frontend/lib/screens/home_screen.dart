import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart' show ProductDetailScreen;

class HomeScreen extends StatefulWidget {
  final String userId;
  final String token;
  const HomeScreen({required this.userId, required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _categories  = [];
  List<dynamic> _products    = [];
  String _selectedCategory   = 'All';
  bool _loading              = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cats  = await ApiService.getCategories();
    final prods = await ApiService.getProducts();
    if (!mounted) return;
    setState(() {
      _categories = [{'name': 'All'}, ...cats];
      _products   = prods;
      _loading    = false;
    });
  }

  List<dynamic> get _filteredProducts {
    if (_selectedCategory == 'All') return _products;
    return _products
        .where((p) => p['category'] == _selectedCategory)
        .toList();
  }

  Future<void> _addToCart(Map<String, dynamic> product) async {
    final productId = product['product_id']?.toString() ??
                      product['id']?.toString() ?? '';
    final ok = await ApiService.addToCart(
      widget.userId, widget.token, productId, 1);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? '${product['name']} added to cart!' : 'Failed to add item'),
        backgroundColor: ok ? const Color(0xFFfb542b) : Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0), // warm cream background
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFB347), 
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.bolt, color: Color(0xFFfb542b), size: 24),
            const SizedBox(width: 6),
            const Text('blinkit',
              style: TextStyle(
                color: Color(0xFFfb542b), fontSize: 22,
                fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            const SizedBox(width: 8),
            const Icon(Icons.location_on, color: Colors.grey, size: 16),
            const Text('Delivery in 10 min',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF000000)),
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(
                builder: (_) => CartScreen(
                  userId: widget.userId, token: widget.token))),
          ),
        ],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFfb542b)))
        : RefreshIndicator(
            color: const Color(0xFFfb542b),
            onRefresh: _loadData,
            child: CustomScrollView(
              slivers: [
                // Search bar
                SliverToBoxAdapter(child: _buildSearchBar()),

                // Category chips
                SliverToBoxAdapter(child: _buildCategoryBar()),

                // Section header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      _selectedCategory == 'All'
                        ? 'All Products'
                        : _selectedCategory,
                      style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A)),
                    ),
                  ),
                ),

                // Products grid
                if (_filteredProducts.isEmpty)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text('No products found',
                          style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _ProductCard(
                          product: _filteredProducts[i],
                          onAddToCart: () => _addToCart(_filteredProducts[i]),
                          onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(
                                product: _filteredProducts[i],
                                userId: widget.userId,
                                token: widget.token,
                              ))),
                        ),
                        childCount: _filteredProducts.length,
                      ),
                      gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: const Color(0xFFFFB347),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          children: [
            SizedBox(width: 12),
            Icon(Icons.search, color: Colors.grey, size: 20),
            SizedBox(width: 8),
            Text('Search for products...',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBar() {
    return Container(
      color: const Color(0xFFFFF3E0), // warm orange category bar
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final cat  = _categories[i]['name'] as String;
          final sel  = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFFFF8C42) : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(cat,
                style: TextStyle(
                  color: sel ? Colors.white : Colors.black87,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                )),
            ),
          );
        },
      ),
    );
  }
}

// ─── Product Card ────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final name      = product['name'] ?? 'Product';
    final price     = product['price']?.toString() ?? '0';
    final imageUrl  = product['image_url'] as String?;
    final available = product['available'] as bool? ?? true;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF5), // warm white card
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.08),
              blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Expanded(
              child: ClipRRect(
                borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
                child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13, color: Color(0xFF1A1A1A))),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹$price',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14, color: Color(0xFFfb542b))), // orange price
                      if (available)
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFfb542b), // orange add button
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.add,
                              color: Colors.white, size: 18),
                          ),
                        )
                      else
                        const Text('Out of stock',
                          style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: const Color(0xFFFFECCC), // warm placeholder
    child: const Center(
      child: Icon(Icons.image_not_supported_outlined,
        color: Colors.orange, size: 40)),
  );
}