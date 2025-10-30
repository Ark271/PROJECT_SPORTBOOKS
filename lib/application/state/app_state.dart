import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/entities.dart'; // dùng Address, Book, CartItem, Order
import '../../data/datasources/memory.dart'; // MemoryDataSource cho catalog/wishlist/cart/orders

/// Model thông báo tối giản dùng chung
class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt; // để hiển thị time label
  bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });
}

class ProfileNotiState extends ChangeNotifier {
  ProfileNotiState();

  // ===== PROFILE / ADDRESS =====
  Address? _address;
  Address? get address => _address;

  void setAddress(Address? a) {
    _address = a;
    notifyListeners();
  }

  // ===== NOTIFICATIONS =====
  final List<AppNotification> _notifications = <AppNotification>[];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadNoti => _notifications.where((n) => !n.read).length;

  /// Hỗ trợ 2 kiểu:
  /// - addNotification(AppNotification(...))
  /// - addNotification('Tiêu đề', 'Nội dung')
  void addNotification(dynamic a, [String? b]) {
    AppNotification n;
    if (a is AppNotification) {
      n = a;
    } else if (a is String && b is String) {
      n = AppNotification(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: a,
        body: b,
        createdAt: DateTime.now(),
      );
    } else {
      // Sai định dạng, bỏ qua
      return;
    }
    _notifications.insert(0, n);
    notifyListeners();
  }

  void markAllRead() {
    for (final n in _notifications) {
      n.read = true;
    }
    notifyListeners();
  }

  void markOneRead(String id) {
    final i = _notifications.indexWhere((e) => e.id == id);
    if (i >= 0) {
      _notifications[i].read = true;
      notifyListeners();
    }
  }

  // ===== LOAD / PERSIST (tùy chọn) =====
  Future<void> loadInitial() async {
    try {
      // _address = await ds.loadAddress();
      // _notifications
      //   ..clear()
      //   ..addAll(await ds.loadNotifications());
      notifyListeners();
    } catch (_) {}
  }
}

class CatalogWishlistSettingsState extends ChangeNotifier {
  final MemoryDataSource ds;

  CatalogWishlistSettingsState({MemoryDataSource? dataSource})
    : ds = dataSource ?? MemoryDataSource();

  // ===== SETTINGS (Theme) =====
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  Future<void> toggleThemeAndPersist() async {
    _themeMode = (_themeMode == ThemeMode.dark)
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
  }

  // ===== CATALOG + SEARCH =====
  List<Book> get catalog => ds.catalog;

  String _query = '';
  String get query => _query;

  /// Danh sách hiển thị sau search/filter
  List<Book> get catalogView {
    if (_query.trim().isEmpty) return catalog;
    final q = _query.toLowerCase();
    return catalog
        .where((b) {
          return b.title.toLowerCase().contains(q) ||
              b.author.toLowerCase().contains(q) ||
              b.category.toLowerCase().contains(q);
        })
        .toList(growable: false);
  }

  void doSearch(String q) {
    _query = q;
    notifyListeners();
  }

  // ===== WISHLIST =====
  final Set<String> _wish = <String>{};
  Set<String> get wishlistIds => Set.unmodifiable(_wish);

  Future<void> toggleWishlist(String bookId) async {
    if (_wish.contains(bookId)) {
      _wish.remove(bookId);
    } else {
      _wish.add(bookId);
    }
    await _persistWishlist();
    notifyListeners();
  }

  bool inWishlist(String bookId) => _wish.contains(bookId);

  Future<void> _persistWishlist() async {
    await ds.saveWishlistIds(_wish.toList());
  }

  // ===== LOAD INITIAL (phần của trinhduyan) =====
  Future<void> loadInitial() async {
    try {
      // WISHLIST
      final ids = await ds.loadWishlistIds();
      _wish
        ..clear()
        ..addAll(ids);

      // SETTINGS (nếu bạn lưu ThemeMode ở ds thì load ở đây)
      // _themeMode = await ds.loadThemeMode() ?? ThemeMode.light;

      notifyListeners();
    } catch (_) {}
  }
}

class CartCheckoutOrdersState extends ChangeNotifier {
  final MemoryDataSource ds;

  CartCheckoutOrdersState({MemoryDataSource? dataSource})
    : ds = dataSource ?? MemoryDataSource();

  // ---------------- CART ----------------
  final List<CartItem> _cart = <CartItem>[];
  List<CartItem> get cart => List.unmodifiable(_cart);

  Future<void> addToCart(Book b, {int qty = 1}) async {
    final idx = _cart.indexWhere((e) => e.book.id == b.id);
    if (idx >= 0) {
      final item = _cart[idx];
      _cart[idx] = item.copyWith(qty: item.qty + qty);
    } else {
      _cart.add(CartItem(book: b, qty: qty));
    }
    await ds.saveCart(_cart);
    notifyListeners();
  }

  Future<void> addOne(Book b) => addToCart(b, qty: 1);

  Future<void> incOne(String bookId) async {
    final idx = _cart.indexWhere((e) => e.book.id == bookId);
    if (idx >= 0) {
      final it = _cart[idx];
      _cart[idx] = it.copyWith(qty: it.qty + 1);
      await ds.saveCart(_cart);
      notifyListeners();
    }
  }

  Future<void> decOne(String bookId) async {
    final idx = _cart.indexWhere((e) => e.book.id == bookId);
    if (idx >= 0) {
      final it = _cart[idx];
      final n = it.qty - 1;
      if (n <= 0) {
        _cart.removeAt(idx);
      } else {
        _cart[idx] = it.copyWith(qty: n);
      }
      await ds.saveCart(_cart);
      notifyListeners();
    }
  }

  Future<void> removeItem(String bookId) async {
    _cart.removeWhere((e) => e.book.id == bookId);
    await ds.saveCart(_cart);
    notifyListeners();
  }

  Future<void> setCartQty(String bookId, int qty) async {
    final idx = _cart.indexWhere((e) => e.book.id == bookId);
    if (idx >= 0) {
      if (qty <= 0) {
        _cart.removeAt(idx);
      } else {
        _cart[idx] = _cart[idx].copyWith(qty: qty);
      }
      await ds.saveCart(_cart);
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _cart.clear();
    await ds.saveCart(_cart);
    notifyListeners();
  }

  int get cartSubtotal =>
      _cart.fold(0, (s, it) => s + it.book.salePrice * it.qty);

  // ---------------- CHECKOUT (logic trong state) ----------------
  // Dùng: cartSubtotal + (đọc Address từ ProfileNotiState ở UI).
  int _shippingFee = 0;
  int get shippingFee => _shippingFee;
  void setShippingFee(int v) {
    _shippingFee = (v < 0) ? 0 : v;
    notifyListeners();
  }

  String _paymentMethod = 'COD'; // ví dụ: COD | MoMo | VNPAY
  String get paymentMethod => _paymentMethod;
  void setPaymentMethod(String m) {
    _paymentMethod = m;
    notifyListeners();
  }

  int get totalPayable => cartSubtotal + _shippingFee;

  // ---------------- ORDERS ----------------
  final List<Order> _orders = <Order>[];
  List<Order> get orders => List.unmodifiable(_orders);

  Future<void> addOrder(Order o) async {
    _orders.add(o);
    await ds.saveOrders(_orders);
    notifyListeners();
  }

  OrderStatus statusOf(String orderId) {
    // Demo: giả sử tất cả đơn đều 'done'
    return OrderStatus.done;
  }

  String methodOf(String orderId) {
    final i = _orders.indexWhere((e) => e.id == orderId);
    if (i >= 0) return _orders[i].method;
    return 'COD';
  }

  // ---------------- LOAD / PERSIST ----------------
  Future<void> loadInitial() async {
    try {
      // CART
      final c = await ds.loadCart();
      _cart
        ..clear()
        ..addAll(c);

      // ORDERS
      final os = await ds.loadOrders();
      _orders
        ..clear()
        ..addAll(os);

      notifyListeners();
    } catch (_) {}
  }
}
