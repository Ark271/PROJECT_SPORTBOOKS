import 'package:flutter/foundation.dart';
import '../../domain/entities/entities.dart';
import '../../domain/usecases/add_to_cart_uc.dart';
import '../../domain/usecases/change_qty_uc.dart';
import '../../domain/usecases/get_cart_stream_uc.dart';
import '../../domain/usecases/get_subtotal_uc.dart';

class CartVm extends ChangeNotifier {
  final GetCartStreamUc getStream;
  final AddToCartUc addToCart;
  final ChangeQtyUc changeQty;
  final GetSubtotalUc getSubtotal;

  List<CartItem> items = const [];

  CartVm({
    required this.getStream,
    required this.addToCart,
    required this.changeQty,
    required this.getSubtotal,
  }) {
    getStream.stream().listen((v) {
      items = v;
      notifyListeners();
    });
  }

  Future<void> add(Book b) => addToCart.add(b);
  Future<void> setQty(Book b, int q) => changeQty.setQty(b, q);

  double subtotal() => getSubtotal.calculate(items);
}

