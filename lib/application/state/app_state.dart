import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/entities.dart'; // dùng Address
// Nếu bạn đã có MemoryDataSource cho Address/Noti, có thể import và dùng ở TODO.


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
