import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';

class MemoryDataSource {
  // ==== Catalog demo ====
  final List<Book> _catalog = <Book>[
    // (Giữ vài mẫu — bạn có thể thêm/bớt theo dự án)
    Book(
      id: 'b1',
      title: 'Lập Trình Flutter Cơ Bản',
      author: 'Nguyễn An',
      category: 'Kỹ thuật',
      image: 'https://picsum.photos/seed/flutter-basic/300/400',
      price: 150000,
      salePercent: 20,
      salePrice: 120000,
      soldCount: 520,
      ratingAvg: 4.5,
      description: 'Học Flutter từ cơ bản đến triển khai app đầu tiên.',
      publishedAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    Book(
      id: 'b2',
      title: 'Dart Nâng Cao',
      author: 'Trần Bảo',
      category: 'Kỹ thuật',
      image: 'https://picsum.photos/seed/dart-advanced/300/400',
      price: 180000,
      salePercent: 10,
      salePrice: 162000,
      soldCount: 620,
      ratingAvg: 4.2,
      description: 'Generics, isolates, async/await chuyên sâu.',
      publishedAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    Book(
      id: 'b3',
      title: 'Clean Architecture Thực Chiến',
      author: 'Phạm Khang',
      category: 'Kỹ thuật',
      image: 'https://picsum.photos/seed/clean-arch/300/400',
      price: 220000,
      salePercent: 0,
      salePrice: 220000,
      soldCount: 320,
      ratingAvg: 4.6,
      description: 'Áp dụng Clean Architecture cho Flutter với ví dụ cụ thể.',
      publishedAt: DateTime.now().subtract(const Duration(days: 150)),
    ),
    // ... (bạn có thể bổ sung thêm các nhóm Văn học/Kinh doanh)
  ];

  List<Book> get catalog => List.unmodifiable(_catalog);

  // ==== Reviews (in-memory) ====
  // final Map<String, List<Review>> _bookReviews = <String, List<Review>>{};

  // Future<List<Review>> loadReviews(String bookId) async =>
  //     List<Review>.unmodifiable(_bookReviews[bookId] ?? const <Review>[]);

  // Future<void> addReview(String bookId, Review review) async {
  //   final list = _bookReviews.putIfAbsent(bookId, () => <Review>[]);
  //   list.add(review); // an toàn, không dùng '!'
  // }

  // ==== Cart / Wishlist / Orders (in-memory) ====
  final List<CartItem> _cart = <CartItem>[];
  final Set<String> _wishlistIds = <String>{};
  final List<Order> _orders = <Order>[];

  Future<List<CartItem>> loadCart() async => List<CartItem>.unmodifiable(_cart);

  Future<void> saveCart(List<CartItem> items) async {
    _cart
      ..clear()
      ..addAll(items);
  }

  // Tương thích mới (Set) & cũ (Ids)
  Future<Set<String>> loadWishlist() async => Set<String>.from(_wishlistIds);

  Future<void> saveWishlist(Set<String> ids) async {
    _wishlistIds
      ..clear()
      ..addAll(ids);
  }

  // Alias theo tên cũ mà AppState đang gọi
  Future<Set<String>> loadWishlistIds() async => loadWishlist();

  Future<void> saveWishlistIds(List<String> ids) async =>
      saveWishlist(ids.toSet());

  Future<List<Order>> loadOrders() async => List<Order>.unmodifiable(_orders);

  Future<void> saveOrders(List<Order> orders) async {
    _orders
      ..clear()
      ..addAll(orders);
  }

  // ==== Image helper ====
  static Widget safeImage(String url, {BoxFit? fit}) {
    if (url.isEmpty) return const Icon(Icons.image_not_supported);
    return Image.network(
      url,
      fit: fit ?? BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined),
    );
  }
}

// ===== Review: tương thích AppState & UI (rating/text/createdAt) =====
class Review {
  final int rating; // 1..5
  final String text;
  final DateTime createdAt;
  final String? user; // tuỳ chọn

  const Review({
    required this.rating,
    required this.text,
    required this.createdAt,
    this.user,
  });
}
