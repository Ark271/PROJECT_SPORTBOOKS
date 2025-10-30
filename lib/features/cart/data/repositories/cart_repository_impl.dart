import 'dart:async';

import '../../domain/entities/entities.dart';
import '../../domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final _ctrl = StreamController<List<CartItem>>.broadcast();
  final List<CartItem> _items = [];

  CartRepositoryImpl() {
    _emit();
  }

  void _emit() => _ctrl.add(List.unmodifiable(_items));

  @override
  Stream<List<CartItem>> stream() => _ctrl.stream;

  @override
  Future<void> add(Book book) async {
    final i = _items.indexWhere((e) => e.book.id == book.id);
    if (i >= 0) {
      final cur = _items[i];
      _items[i] = cur.copyWith(qty: cur.qty + 1);
    } else {
      _items.add(CartItem(book: book, qty: 1));
    }
    _emit();
  }

  @override
  Future<void> setQty(Book book, int qty) async {
    final i = _items.indexWhere((e) => e.book.id == book.id);
    if (i < 0) return;
    if (qty <= 0) {
      _items.removeAt(i);
    } else {
      _items[i] = _items[i].copyWith(qty: qty);
    }
    _emit();
  }

  @override
  Future<void> remove(Book book) async {
    _items.removeWhere((e) => e.book.id == book.id);
    _emit();
  }
}

