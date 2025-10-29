import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/entities.dart'; // dùng Address & Book
import '../../data/datasources/memory.dart'; // dùng MemoryDataSource cho catalog/wishlist

/// Item thông báo tối giản cho UI
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
  /// Gọi lúc khởi động app để nạp Address/Noti đã lưu (nếu bạn có cơ chế lưu).
  Future<void> loadInitial() async {
    try {
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
