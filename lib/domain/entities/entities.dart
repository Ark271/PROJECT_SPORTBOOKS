// lib/domain/entities/entities.dart

class Book {
  final String id, title, author, category, image;
  final int price, salePrice; // UI dùng int
  final int salePercent, soldCount;
  final double ratingAvg; // UI có xếp hạng TB
  final String description; // UI đọc description
  final DateTime? publishedAt, flashSaleEnd;

  const Book({
    required this.id,
    required this.title,
    this.author = '',
    this.category = 'Tất cả',
    this.image = '',
    required this.price,
    this.salePercent = 0,
    required this.salePrice,
    this.soldCount = 0,
    this.ratingAvg = 0,
    this.description = '',
    this.publishedAt,
    this.flashSaleEnd,
  });
}

class CartItem {
  final Book book;
  final int qty;
  const CartItem({required this.book, this.qty = 1});

  CartItem copyWith({Book? book, int? qty}) =>
      CartItem(book: book ?? this.book, qty: qty ?? this.qty);

  int get lineTotal => book.salePrice * qty;
}

class Address {
  final String fullName;
  final String phone;
  final String addressLine; // line1
  final String? ward; // phường
  final String? district; // quận/huyện
  final String? city; // tỉnh/thành

  const Address({
    required this.fullName,
    required this.phone,
    required this.addressLine,
    this.ward,
    this.district,
    this.city,
  });

  String get line1 => addressLine;

  /// Chuỗi địa chỉ đầy đủ gộp từ các phần (an toàn null)
  String get address => [
        addressLine,
        if ((ward ?? '').trim().isNotEmpty) ward,
        if ((district ?? '').trim().isNotEmpty) district,
        if ((city ?? '').trim().isNotEmpty) city,
      ]
          .where((e) => (e ?? '').trim().isNotEmpty)
          .map((e) => (e ?? '').trim())
          .join(', ');
}

class Order {
  final String id;
  final List<CartItem> items;
  final DateTime createdAt;
  final String method; // 'COD' / 'MoMo' / 'VNPay' (tuỳ bạn)
  final int total; // UI dùng int

  const Order({
    required this.id,
    required this.items,
    required this.createdAt,
    this.method = "COD",
    required this.total,
  });
}
