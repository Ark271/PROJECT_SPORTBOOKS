// lib/presentation/pages/detail/book_detail.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/state/app_state.dart';
import '../../../core/utils/money.dart';
import '../../../data/datasources/memory.dart' show Review;
import '../../../domain/entities/entities.dart';

/// Alias để các nơi gọi BookDetail(book: ...) không bị lỗi
class BookDetail extends StatelessWidget {
  final Book book;
  const BookDetail({super.key, required this.book});
  @override
  Widget build(BuildContext context) => BookDetailPage(book: book);
}

class BookDetailPage extends StatelessWidget {
  final Book book;
  const BookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final inWish = app.inWishlist(book.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sách'),
        actions: [
          IconButton(
            onPressed: () => app.toggleWishlist(book.id),
            icon: Icon(inWish ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Ảnh + title
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                book.image,
                width: 180,
                height: 240,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image_outlined, size: 120),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            book.title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(book.author.isNotEmpty ? book.author : '—',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                formatVnd(book.salePrice),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 8),
              if (book.salePercent > 0)
                Text(
                  formatVnd(book.price),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        decoration: TextDecoration.lineThrough,
                      ),
                ),
              const Spacer(),
              Chip(
                label: Text(book.category),
                avatar: const Icon(Icons.category_outlined, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Mô tả
          if (book.description.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  book.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Review (demo từ datasource bộ nhớ)
          // FutureBuilder<List<Review>>(
          //   future: _loadReviews(context, book.id),
          //   builder: (context, snap) {
          //     final has = snap.connectionState == ConnectionState.done &&
          //         snap.hasData &&
          //         snap.data != null;
          //     final reviews =
          //         has ? (snap.data as List<Review>) : const <Review>[];

          //     if (reviews.isEmpty) {
          //       return const Card(
          //         child: ListTile(
          //           leading: Icon(Icons.reviews_outlined),
          //           title: Text('Chưa có đánh giá'),
          //         ),
          //       );
          //     }

          //     return Card(
          //       child: Padding(
          //         padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text('Đánh giá',
          //                 style: Theme.of(context)
          //                     .textTheme
          //                     .titleMedium
          //                     ?.copyWith(fontWeight: FontWeight.w800)),
          //             const SizedBox(height: 8),
          //             ...reviews.map(
          //               (r) => ListTile(
          //                 leading: CircleAvatar(
          //                   child: Text(r.rating.toString()),
          //                 ),
          //                 title: Text(r.text),
          //                 subtitle: Text(r.createdAt.toLocal().toString()),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     );
          //   },
          // ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.reviews_outlined),
              title: Text('Chưa có đánh giá'),
            ),
          ),
          const SizedBox(height: 24),

          // Nút thêm vào giỏ
          FilledButton.icon(
            onPressed: () => app.addToCart(book),
            icon: const Icon(Icons.add_shopping_cart_outlined),
            label: const Text('Thêm vào giỏ'),
          ),
        ],
      ),
    );
  }

  // Future<List<Review>> _loadReviews(BuildContext context, String bookId) async {
  //   final ds = context.read<AppState>().ds;
  //   return ds.loadReviews(bookId);
  // }
}
