import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/state/app_state.dart';
import '../../domain/entities/entities.dart';
import '../../data/datasources/memory.dart' show MemoryDataSource;
import '../../core/utils/money.dart';
import '../pages/detail/book_detail.dart';

class BookGrid extends StatelessWidget {
  final List<Book> books;
  final bool embed; // true => lưới không tự cuộn (nhúng)

  const BookGrid({super.key, required this.books, this.embed = false});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final w = MediaQuery.of(context).size.width;
    final cross = w >= 1200
        ? 6
        : w >= 900
        ? 4
        : w >= 600
        ? 3
        : 2;

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      // ✅ an toàn khi nhúng + shrinkWrap
      primary: false,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        // Giữ card cao hơn chút để tránh tràn trên máy nhỏ
        childAspectRatio: 0.76,
      ),
      itemCount: books.length,
      // ✅ đúng quy tắc nhúng: tự co & không cuộn lồng
      shrinkWrap: embed,
      physics: embed ? const NeverScrollableScrollPhysics() : null,
      itemBuilder: (context, i) {
        final b = books[i];
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BookDetail(book: b)),
          ),
          child: Card(
            elevation: 1.5,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                AspectRatio(
                  // ảnh giữ tỉ lệ này là hợp lý với card cao hơn
                  aspectRatio: 5 / 4,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MemoryDataSource.safeImage(b.image, fit: BoxFit.cover),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            formatVnd(b.salePrice),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          ),
                        ),
                      ),
                      if (b.salePercent > 0)
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
                              '-${b.salePercent}%',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tiêu đề 1 dòng
                        Text(
                          b.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        // Tác giả 1 dòng
                        Text(
                          b.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star,
                                size: 14, color: Colors.amber[700]),
                            const SizedBox(width: 2),
                            Text(b.ratingAvg.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 8),
                            Text('Đã bán ${b.soldCount}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                        if (b.salePercent > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            formatVnd(b.price),
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.black45,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const Spacer(),

                        // ✅ Sửa tối thiểu: không để button bị ép minWidth = ∞ trong ngữ cảnh chặt
                        ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 0),
                          child: SizedBox(
                            width: double
                                .infinity, // vẫn full theo card (không đổi UI)
                            child: ElevatedButton(
                              onPressed: () => app.addOne(b),
                              style: ElevatedButton.styleFrom(
                                // giữ chiều cao nhỏ gọn, KHÔNG ép width vô hạn
                                minimumSize: const Size(0, 36),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                padding:
                                const EdgeInsets.symmetric(vertical: 2.5),
                                shape: const StadiumBorder(),
                                elevation: 0.5,
                                backgroundColor: const Color(0xFFF2F2F7),
                                foregroundColor: Colors.black87,
                                textStyle: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text('Thêm vào giỏ'),
                            ),
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
      },
    );
  }
}
