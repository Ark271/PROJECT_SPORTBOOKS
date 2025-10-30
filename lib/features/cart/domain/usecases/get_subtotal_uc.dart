import '../entities/entities.dart';

class GetSubtotalUc {
  /// Tính tạm tính ngay trên domain.
  double calculate(List<CartItem> items) =>
      items.fold<double>(0.0, (t, it) => t + it.book.salePrice * it.qty);
}

