import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/state/app_state.dart';
import '../../domain/entities/entities.dart';
import '../../core/utils/money.dart';

class OrderDetailPage extends StatelessWidget {
  final Order order;
  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final st = app.statusOf(order.id);
    final method = app.methodOf(order.id);
    final addr = app.address; // có thể null nếu người dùng chưa lưu

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== Thông tin chung =====
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mã đơn: ${order.id}',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  _kv('Trạng thái', _statusText(st)),
                  _kv('Phương thức', method),
                  _kv(
                    'Ngày tạo',
                    '${order.createdAt.day.toString().padLeft(2, '0')}/'
                        '${order.createdAt.month.toString().padLeft(2, '0')}/'
                        '${order.createdAt.year}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ===== Địa chỉ giao =====
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(addr?.fullName ?? 'Người nhận'),
              subtitle: Text(
                [
                  if ((addr?.phone ?? '').isNotEmpty) addr?.phone ?? '',
                  if ((addr?.line1 ?? '').isNotEmpty) addr?.line1 ?? '',
                  if ((addr?.city ?? '').isNotEmpty) addr?.city ?? '',
                ].join('  '),
              ),
              trailing: addr == null
                  ? const Icon(Icons.warning_amber_rounded,
                      color: Colors.orange)
                  : null,
            ),
          ),
          const SizedBox(height: 12),

          // ===== Danh sách sản phẩm =====
          Text('Sản phẩm',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          ...order.items.map(
            (it) => Card(
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    it.book.image,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image_outlined,
                      size: 40,
                    ),
                  ),
                ),
                title: Text(
                  it.book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('x${it.qty} • ${formatVnd(it.book.salePrice)}'),
                trailing: Text(
                  formatVnd(it.lineTotal),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ===== Tổng kết =====
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tổng kết',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  _kv('Tạm tính', formatVnd(_subtotal(order))),
                  _kv('Giảm giá', '- ' + formatVnd(_discount(order))),
                  _kv('Phí vận chuyển', formatVnd(_shippingFee(order))),
                  const Divider(height: 20),
                  _kv('Tổng cộng', formatVnd(order.total), bold: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ===== Nút hành động =====
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Quay lại'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ===== Helper =====

  String _statusText(OrderStatus st) {
    switch (st) {
      case OrderStatus.pending:
        return 'Chờ thanh toán';
      case OrderStatus.paid:
        return 'Đã thanh toán';
      case OrderStatus.shipping:
        return 'Đang giao';
      case OrderStatus.done:
        return 'Hoàn thành';
    }
  }

  int _subtotal(Order o) =>
      o.items.fold<int>(0, (s, it) => s + it.book.salePrice * it.qty);

  int _discount(Order o) {
    // Nếu trong dự án bạn có chiết khấu riêng cho Order, thay đổi logic ở đây
    final sub = _subtotal(o);
    final d = (sub - o.total) - _shippingFee(o);
    return d > 0 ? d : 0;
  }

  int _shippingFee(Order o) {
    // Nếu có field phí ship riêng, thay đổi logic này cho khớp
    // Ở đây giả định: total = subtotal - discount + shipping
    final sub = _subtotal(o);
    final disc = _discount(o);
    final fee = o.total - (sub - disc);
    return fee >= 0 ? fee : 0;
  }

  Widget _kv(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
