import 'package:flutter/material.dart';

/// Hợp đồng trừu tượng (Contract) dành riêng cho các UI Component tích hợp BLoC.
/// Không chứa `setState`, không chứa dữ liệu cục bộ.
mixin InfiniteScrollNotificationHandler {
  /// Trả về trạng thái hiện tại từ BLoC để kiểm tra xem có đang load hoặc hết data không.
  /// Phía UI (Concrete Widget) bắt buộc phải truyền giá trị từ BLoC State vào đây.
  bool get isDataLoading;
  bool get hasMoreDataToLoad;

  /// Hàm trigger gửi Event tới BLoC. Phía UI sẽ hiện thực: bloc.add(FetchNextPageEvent())
  void onTriggerLoadMore();

  /// Hàm xử lý sự kiện cuộn từ NotificationListener.
  /// Hoàn toàn độc lập với UI State, không gây Rebuild.
  bool handleScrollNotification(
    ScrollNotification notification, {
    double threshold = 0.8,
  }) {
    if (notification is! ScrollUpdateNotification) return false;

    // Kiểm tra chốt chặn (Guard Clauses) từ BLoC State trước khi xử lý tính toán
    if (!hasMoreDataToLoad || isDataLoading) return false;

    final metrics = notification.metrics;
    final maxScroll = metrics.maxScrollExtent;
    final currentScroll = metrics.pixels;

    // Nếu vượt ngưỡng threshold, trigger gửi event tới BLoC
    if (currentScroll >= (maxScroll * threshold)) {
      onTriggerLoadMore();
    }

    return false; // Cho phép notification tiếp tục nổi bọt nếu cần
  }
}
