import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/state/app_state.dart';
import '../../core/utils/money.dart';

class TabCart extends StatelessWidget {
  const TabCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, app, _) {
        final items = app.cart;
        final subtotal = app.cartSubtotal;

        return Scaffold(
          appBar: AppBar(title: const Text('Giỏ hàng')),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Danh sách — phải đặt trong Expanded
                Expanded(
                  child: items.isEmpty
                      ? const Center(child: Text('Giỏ hàng trống'))
                      : ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final it = items[i];
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  it.book.image,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.broken_image_outlined,
                                      size: 40),
                                ),
                              ),
                              title: Text(it.book.title,
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                              subtitle: Text(
                                  'x${it.qty} • ${formatVnd(it.book.salePrice)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => app.decOne(it.book.id),
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                  ),
                                  Text('${it.qty}'),
                                  IconButton(
                                    onPressed: () => app.incOne(it.book.id),
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                  IconButton(
                                    onPressed: () => app.removeItem(it.book.id),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                // Tổng kết + nút thanh toán
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Tạm tính: ${formatVnd(subtotal)}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        FilledButton(
                          onPressed: items.isEmpty
                              ? null
                              : () =>
                                  Navigator.of(context).pushNamed('/checkout'),
                          child: const Text('Thanh toán'),
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
