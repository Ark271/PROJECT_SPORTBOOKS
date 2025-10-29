import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/state/app_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  String timeLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, app, _) {
        final items = app.notifications;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Thông báo'),
            actions: [
              if (app.unreadNoti > 0)
                TextButton(
                  onPressed: () => context.read<AppState>().markAllRead(),
                  child: const Text('Đánh dấu đã đọc',
                      style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // ListView phải đặt trong Expanded
                Expanded(
                  child: items.isEmpty
                      ? const Center(child: Text('Chưa có thông báo'))
                      : ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final n = items[i];
                            return ListTile(
                              leading: Icon(
                                n.read
                                    ? Icons.notifications
                                    : Icons.notifications_active,
                              ),
                              title: Text(n.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              subtitle:
                                  Text('${n.body}\n${timeLabel(n.createdAt)}'),
                              isThreeLine: true,
                              onTap: () =>
                                  context.read<AppState>().markOneRead(n.id),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Thêm nhanh 1 thông báo mẫu để test
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.read<AppState>().addNotification(
                    'Khuyến mãi',
                    'Nhập mã SPORT10 để giảm 10% đơn hàng hôm nay!',
                  );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
