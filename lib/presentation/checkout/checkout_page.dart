import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/state/app_state.dart';
import '../../core/utils/money.dart';
import '../../data/datasources/memory.dart' show MemoryDataSource;
import '../../domain/entities/entities.dart';

enum ShippingType { innerCity, suburban, express }

enum PaymentMethod { cod, momo, vnpay }

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _couponCtl = TextEditingController();
  String? _couponError;
  int _couponPercent = 0;

  ShippingType _ship = ShippingType.innerCity;
  PaymentMethod _pay = PaymentMethod.cod;

  Address? _addr;

  final Map<String, int> _couponTable = const <String, int>{
    'SPORT5': 5,
    'SPORT10': 10,
    'NEWUSER': 15,
  };

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    _addr = app.address;
  }

  @override
  void dispose() {
    _couponCtl.dispose();
    super.dispose();
  }

  int _shippingFee(ShippingType t) {
    switch (t) {
      case ShippingType.innerCity:
        return 15000;
      case ShippingType.suburban:
        return 30000;
      case ShippingType.express:
        return 45000;
    }
  }

  void _applyCoupon() {
    final code = _couponCtl.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() {
        _couponPercent = 0;
        _couponError = 'Nhập mã giảm giá';
      });
      return;
    }
    if (_couponTable.containsKey(code)) {
      setState(() {
        _couponPercent = _couponTable[code] ?? 0; // an toàn null
        _couponError = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Áp dụng mã $code: giảm $_couponPercent%')),
      );
    } else {
      setState(() {
        _couponPercent = 0;
        _couponError = 'Mã không hợp lệ';
      });
    }
  }

  int _subtotal(List<CartItem> items) =>
      items.fold<int>(0, (s, it) => s + it.book.salePrice * it.qty);

  int _discountValue(int subtotal) => (subtotal * _couponPercent ~/ 100);

  int _grandTotal({
    required List<CartItem> items,
    required ShippingType ship,
    required int couponPercent,
  }) {
    final sub = _subtotal(items);
    final disc = _discountValue(sub);
    final shipFee = _shippingFee(ship);
    return (sub - disc + shipFee).clamp(0, 1 << 31);
  }

  Future<void> _placeOrder(AppState app) async {
    final items = app.cart;
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giỏ hàng đang trống')),
      );
      return;
    }
    if (_addr == null ||
        (_addr!.fullName.trim().isEmpty ||
            _addr!.phone.trim().isEmpty ||
            _addr!.addressLine.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ giao hàng')),
      );
      return;
    }

    final sub = _subtotal(items);
    final disc = _discountValue(sub);
    final fee = _shippingFee(_ship);
    final total = (sub - disc + fee).clamp(0, 1 << 31);

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: List<CartItem>.from(items),
      createdAt: DateTime.now(),
      method: _pay == PaymentMethod.cod
          ? 'COD'
          : (_pay == PaymentMethod.momo ? 'MoMo' : 'VNPay'),
      total: total,
    );

    // Hai hàm này cần có trong AppState (xem ghi chú bên dưới)
    await app.addOrder(order);
    await app.clearCart();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đặt hàng thành công!')),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final items = app.cart;

    final subtotal = _subtotal(items);
    final discount = _discountValue(subtotal);
    final shipFee = _shippingFee(_ship);
    final total = _grandTotal(
      items: items,
      ship: _ship,
      couponPercent: _couponPercent,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== Địa chỉ nhận hàng =====
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Địa chỉ nhận hàng',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _addr?.fullName ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Họ tên người nhận',
                    ),
                    onChanged: (v) => _addr = Address(
                      fullName: v,
                      phone: _addr?.phone ?? '',
                      addressLine: _addr?.addressLine ?? '',
                      ward: _addr?.ward,
                      district: _addr?.district,
                      city: _addr?.city,
                    ),
                  ),
                  TextFormField(
                    initialValue: _addr?.phone ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (v) => _addr = Address(
                      fullName: _addr?.fullName ?? '',
                      phone: v,
                      addressLine: _addr?.addressLine ?? '',
                      ward: _addr?.ward,
                      district: _addr?.district,
                      city: _addr?.city,
                    ),
                  ),
                  TextFormField(
                    initialValue: _addr?.addressLine ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ (số nhà, đường)',
                    ),
                    onChanged: (v) => _addr = Address(
                      fullName: _addr?.fullName ?? '',
                      phone: _addr?.phone ?? '',
                      addressLine: v,
                      ward: _addr?.ward,
                      district: _addr?.district,
                      city: _addr?.city,
                    ),
                  ),
                  TextFormField(
                    initialValue: _addr?.city ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Tỉnh/Thành',
                    ),
                    onChanged: (v) => _addr = Address(
                      fullName: _addr?.fullName ?? '',
                      phone: _addr?.phone ?? '',
                      addressLine: _addr?.addressLine ?? '',
                      ward: _addr?.ward,
                      district: _addr?.district,
                      city: v,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () =>
                          context.read<AppState>().setAddress(_addr),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Lưu địa chỉ'),
                    ),
                  ),
                ],
              ),
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
          if (items.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.shopping_cart_outlined),
                title: Text('Giỏ hàng trống'),
              ),
            ),
          ...items.map(
            (it) => Card(
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    it.book.image,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image_outlined, size: 40),
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

          // ===== Vận chuyển =====
          Text('Vận chuyển',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Card(
            child: Column(
              children: [
                RadioListTile<ShippingType>(
                  value: ShippingType.innerCity,
                  groupValue: _ship,
                  onChanged: (v) => setState(() => _ship = v!),
                  title: const Text('Nội thành (tiết kiệm)'),
                  subtitle: Text(
                      'Phí: ${formatVnd(_shippingFee(ShippingType.innerCity))} • 1–2 ngày'),
                ),
                RadioListTile<ShippingType>(
                  value: ShippingType.suburban,
                  groupValue: _ship,
                  onChanged: (v) => setState(() => _ship = v!),
                  title: const Text('Ngoại thành'),
                  subtitle: Text(
                      'Phí: ${formatVnd(_shippingFee(ShippingType.suburban))} • 2–4 ngày'),
                ),
                RadioListTile<ShippingType>(
                  value: ShippingType.express,
                  groupValue: _ship,
                  onChanged: (v) => setState(() => _ship = v!),
                  title: const Text('Hoả tốc (trong ngày)'),
                  subtitle: Text(
                      'Phí: ${formatVnd(_shippingFee(ShippingType.express))}'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ===== Thanh toán =====
          Text('Phương thức thanh toán',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Card(
            child: Column(
              children: [
                RadioListTile<PaymentMethod>(
                  value: PaymentMethod.cod,
                  groupValue: _pay,
                  onChanged: (v) => setState(() => _pay = v!),
                  title: const Text('Thanh toán khi nhận hàng (COD)'),
                ),
                RadioListTile<PaymentMethod>(
                  value: PaymentMethod.momo,
                  groupValue: _pay,
                  onChanged: (v) => setState(() => _pay = v!),
                  title: const Text('MoMo'),
                ),
                RadioListTile<PaymentMethod>(
                  value: PaymentMethod.vnpay,
                  groupValue: _pay,
                  onChanged: (v) => setState(() => _pay = v!),
                  title: const Text('VNPay'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ===== Mã giảm giá =====
          Text('Mã giảm giá',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponCtl,
                  decoration: InputDecoration(
                    hintText: 'Nhập mã (VD: SPORT10)',
                    errorText: _couponError,
                    prefixIcon: const Icon(Icons.sell_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _applyCoupon,
                child: const Text('Áp dụng'),
              ),
            ],
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
                  _kv('Tạm tính', formatVnd(subtotal)),
                  _kv('Giảm giá', '- ' + formatVnd(discount)),
                  _kv('Phí vận chuyển', formatVnd(shipFee)),
                  const Divider(height: 20),
                  _kv('Tổng cộng', formatVnd(total), bold: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ===== Đặt hàng =====
          FilledButton.icon(
            onPressed: () => _placeOrder(app),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Đặt hàng'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _kv(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style:
                TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
