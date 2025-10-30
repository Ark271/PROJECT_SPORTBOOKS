import '../entities/entities.dart';
import '../repositories/cart_repository.dart';

class GetCartStreamUc {
  final CartRepository repo;
  GetCartStreamUc(this.repo);

  Stream<List<CartItem>> stream() => repo.stream();
}

