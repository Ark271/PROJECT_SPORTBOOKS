import '../entities/entities.dart';
import '../repositories/cart_repository.dart';

class ChangeQtyUc {
  final CartRepository repo;
  ChangeQtyUc(this.repo);

  Future<void> setQty(Book book, int qty) => repo.setQty(book, qty);
}

