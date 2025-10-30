import 'package:flutter/foundation.dart';
import 'package:sports_books/domain/entities/entities.dart';
import 'package:sports_books/domain/usecases/get_catalog_uc.dart';

class CatalogVM extends ChangeNotifier {
  final GetCatalog _getCatalog;

  CatalogVM(this._getCatalog);

  List<Book> _items = const [];
  List<Book> get items => _items;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _getCatalog();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}


