import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/state/app_state.dart';
import '../widgets/book_grid.dart';

class TabHome extends StatefulWidget {
  const TabHome({super.key});

  @override
  State<TabHome> createState() => _TabHomeState();
}

class _TabHomeState extends State<TabHome> {
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, app, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Sports Books'),
            actions: [
              // Nút thông báo + badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/notifications'),
                  ),
                  if (app.unreadNoti > 0)
                    Positioned(
                      right: 8,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          app.unreadNoti > 9 ? '9+' : '${app.unreadNoti}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Ô tìm kiếm: TextField trong Row phải bọc Expanded
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctl,
                        decoration: const InputDecoration(
                          hintText: 'Tìm tên sách, tác giả, thể loại...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onSubmitted: (v) => app.doSearch(v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => app.doSearch(_ctl.text),
                      child: const Text('Tìm'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Lưới sách: luôn đặt trong Expanded để có ràng buộc kích thước
                Expanded(
                  child: app.catalogView.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.menu_book_outlined, size: 56),
                              const SizedBox(height: 8),
                              const Text('Chưa có dữ liệu để hiển thị'),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () {
                                  // reset tìm kiếm → hiển thị toàn bộ catalog
                                  app.doSearch('');
                                  // thêm 1 thông báo nhỏ để xác nhận app còn chạy
                                  app.addNotification(
                                    'Mẹo',
                                    'Danh sách đang rỗng — kiểm tra MemoryDataSource.catalog.',
                                  );
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Tải lại'),
                              ),
                            ],
                          ),
                        )
                      : BookGrid(
                          books: app.catalogView,
                          embed: true,
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
