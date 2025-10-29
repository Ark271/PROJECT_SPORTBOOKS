import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/state/app_state.dart';
import '../../core/utils/money.dart';
import '../../data/datasources/memory.dart' show MemoryDataSource;
import '../../domain/entities/entities.dart';

enum _SortKey { none, popular, newest, topRated, priceLow, priceHigh, onSale }

class TabCatalog extends StatefulWidget {
  const TabCatalog({super.key});
  @override
  State<TabCatalog> createState() => _TabCatalogState();
}

class _TabCatalogState extends State<TabCatalog> {
  final _qCtl = TextEditingController();
  String _query = '';
  String _selectedCategory = 'Tất cả';
  _SortKey _sort = _SortKey.none;

  final List<String> _categories = const [
    'Tất cả',
    'Kỹ thuật',
    'Học tập',
    'Truyện tranh',
    'Thể thao',
    'Kinh tế',
    'Thiếu nhi',
    'Văn học',
  ];

  @override
  void dispose() {
    _qCtl.dispose();
    super.dispose();
  }

  List<Book> _apply(List<Book> src) {
    var list = List<Book>.from(src);

    // 1) Lọc theo từ khóa
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((b) {
        return b.title.toLowerCase().contains(q) ||
            b.author.toLowerCase().contains(q) ||
            (b.category).toLowerCase().contains(q);
      }).toList();
    }

    // 2) Lọc theo danh mục
    if (_selectedCategory != 'Tất cả') {
      list = list.where((b) => b.category == _selectedCategory).toList();
    }

    // 3) Sắp xếp
    switch (_sort) {
      case _SortKey.popular:
        list.sort((a, b) => b.soldCount.compareTo(a.soldCount));
        break;
      case _SortKey.newest:
        list.sort((a, b) => (b.publishedAt ?? DateTime(1900))
            .compareTo(a.publishedAt ?? DateTime(1900)));
        break;
      case _SortKey.topRated:
        list.sort((a, b) => (b.ratingAvg).compareTo(a.ratingAvg));
        list = list.reversed.toList();
        break;
      case _SortKey.priceLow:
        list.sort((a, b) => (a.salePrice).compareTo(b.salePrice));
        break;
      case _SortKey.priceHigh:
        list.sort((a, b) => (b.salePrice).compareTo(a.salePrice));
        break;
      case _SortKey.onSale:
        list.sort((a, b) => (b.salePercent).compareTo(a.salePercent));
        break;
      case _SortKey.none:
        break;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final books = _apply(app.catalog);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thể loại'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        children: [
          // Tìm kiếm
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _qCtl,
                  onSubmitted: (_) => setState(() => _query = _qCtl.text),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Tìm theo tên/tác giả/thể loại',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => setState(() => _query = _qCtl.text),
                child: const Text('Tìm'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Chip danh mục (nằm trên)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((c) {
              final selected = _selectedCategory == c;
              return ChoiceChip(
                label: Text(c),
                selected: selected,
                onSelected: (_) => setState(() => _selectedCategory = c),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Chip sắp xếp/bộ lọc (nổi bật, mới nhất, sale,…)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _sortChip('Phổ biến', _SortKey.popular),
              _sortChip('Mới nhất', _SortKey.newest),
              _sortChip('Đánh giá cao', _SortKey.topRated),
              _sortChip('Giá thấp', _SortKey.priceLow),
              _sortChip('Giá cao', _SortKey.priceHigh),
              _sortChip('Sale', _SortKey.onSale),
            ],
          ),
          const SizedBox(height: 12),

          // Lưới sách
          GridView.builder(
            itemCount: books.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.66, // dáng card giống trang chủ
            ),
            itemBuilder: (_, i) => _BookCard(book: books[i]),
          ),
        ],
      ),
    );
  }

  Widget _sortChip(String label, _SortKey key) {
    final selected = _sort == key;
    return FilterChip.elevated(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _sort = selected ? _SortKey.none : key),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).pushNamed(
        '/book_detail',
        arguments: book,
      ),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MemoryDataSource.safeImage(book.image, fit: BoxFit.cover),
                    if (book.salePercent > 0)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-${book.salePercent}%',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          formatVnd(book.salePrice),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Nội dung
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('${book.ratingAvg.toStringAsFixed(1)}'),
                        const SizedBox(width: 6),
                        Text('Đã bán: ${book.soldCount}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black45)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => app.addOne(book),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Thêm vào giỏ'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
