import '../entities/entities.dart';

abstract class CartRepository {
  Stream<List<CartItem>> stream();

  Future<void> add(Book book); // +1 hoặc thêm mới
  Future<void> setQty(Book book, int qty); // cập nhật số lượng
  Future<void> remove(Book book); // xoá khỏi giỏ
}

