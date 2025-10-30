import '../entities/entities.dart';
import '../repositories/cart_repository.dart';

class AddToCartUc {
  final CartRepository repo;
  AddToCartUc(this.repo);

  Future<void> add(Book book) => repo.add(book);
}

