import '../entities/entities.dart';
import 'package:sports_books/data/datasources/memory.dart';

class GetCatalog {
  final MemoryDataSource ds;
  GetCatalog(this.ds);
  Future<List<Book>> call() async => ds.catalog;
}

