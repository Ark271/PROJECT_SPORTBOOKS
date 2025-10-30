// DOMAIN ENTITIES
class Book {
  final String id;
  final String title;
  final double price; // giá gốc
  final double? salePercent; // 0.0..1.0, có thể null khi không sale

  const Book({
    required this.id,
    required this.title,
    required this.price,
    this.salePercent,
  });

  /// Giá sau khi áp dụng sale.
  double get salePrice {
    final p = salePercent;
    if (p == null) return price;
    return price * (1 - p).clamp(0.0, 1.0);
  }
}

class CartItem {
  final Book book;
  final int qty;
  const CartItem({required this.book, required this.qty});

  CartItem copyWith({Book? book, int? qty}) =>
      CartItem(book: book ?? this.book, qty: qty ?? this.qty);
}

