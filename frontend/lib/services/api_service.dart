import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ── Change this IP to your machine's LAN IP ──
  static const String _host = '192.168.1.4';

  static const String userBase     = 'http://$_host:8001';
  static const String productBase  = 'http://$_host:8002';
  static const String cartBase     = 'http://$_host:8003';
  static const String deliveryBase = 'http://$_host:8004';

  // ─────────────────────────────── USER ────────────────────────────────

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$userBase/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'otp': '1234',
        }),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$userBase/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // ─────────────────────────────── PRODUCTS ────────────────────────────

  static Future<List<dynamic>> getCategories() async {
    try {
      final res = await http.get(Uri.parse('$productBase/categories'));
      if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    } catch (_) {}
    return [];
  }

  static Future<List<dynamic>> getProducts({String? category}) async {
    try {
      final uri = Uri.parse('$productBase/products');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final all = jsonDecode(res.body) as List<dynamic>;
        if (category != null && category != 'All') {
          return all
              .where((p) => p['category'] == category)
              .toList();
        }
        return all;
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>> getProduct(String productId) async {
    try {
      final res =
          await http.get(Uri.parse('$productBase/products/$productId'));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {};
  }

  // ─────────────────────────────── CART ────────────────────────────────

  static Future<bool> addToCart(
      String userId, String token, String productId, int quantity) async {
    try {
      final res = await http.post(
        Uri.parse('$cartBase/cart/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          'product_id': productId,
          'quantity': quantity,
        }),
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /// GET /cart/{user_id}
  static Future<List<dynamic>> getCart(String userId, String token) async {
    try {
      final res = await http.get(
        Uri.parse('$cartBase/cart/$userId'),   // ← fixed URL
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data["items"] as List<dynamic>? ?? [];
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> removeFromCart(
      String userId, String token, String productId, int quantity) async {
    try {
      final res = await http.post(
        Uri.parse('$cartBase/cart/remove'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          'product_id': productId,
          'quantity': quantity,
        }),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────── ORDERS ──────────────────────────────

  static Future<Map<String, dynamic>> createOrder(
      String userId, String token) async {
    try {
      final res = await http.post(
        Uri.parse('$cartBase/order/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'user_id': userId}),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<List<dynamic>> getOrders(String userId, String token) async {
    try {
      final res = await http.get(
        Uri.parse('$cartBase/order/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    } catch (_) {}
    return [];
  }

  // ─────────────────────────────── DELIVERY ────────────────────────────

  /// GET /delivery/{order_id}/status  ← fixed URL
  static Future<String> getOrderStatus(String orderId, String token) async {
    try {
      final res = await http.get(
        Uri.parse('$deliveryBase/delivery/$orderId/status'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['status'] as String? ?? 'UNKNOWN';
      }
    } catch (_) {}
    return 'UNKNOWN';
  }
}