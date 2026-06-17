import 'package:flutter/material.dart';

class AdvancedInfiniteGridView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  // Nhận hàm check từ Mixin cha
  final bool Function(ScrollNotification) onScrollNotification;
  final bool showLoadingIndicator;
  final SliverGridDelegate? gridDelegate;
  final EdgeInsetsGeometry? padding;
  final Widget? loadingWidget;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const AdvancedInfiniteGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.onScrollNotification,
    required this.showLoadingIndicator,
    this.gridDelegate,
    this.padding,
    this.loadingWidget,
    this.shrinkWrap = false,
    this.physics,
  });

  EdgeInsetsGeometry get _padding => padding ?? EdgeInsets.zero;

  static const defaultGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2, // 2 columns
    mainAxisSpacing: 8, // spacing between rows
    crossAxisSpacing: 8, // spacing between columns
    childAspectRatio: 0.7, // ratio between width and height
    mainAxisExtent: 220, // item height (fixed)
  );

  SliverGridDelegate get _gridDelegate {
    // Nếu không có gridDelegate sử dụng defaultGridDelegate
    if (gridDelegate == null) return defaultGridDelegate;

    //
    return gridDelegate!;
  }

  Widget get _buildLoadingIndicator {
    if (!showLoadingIndicator) return const SizedBox();

    // Nếu có widget loading tùy chỉnh, sử dụng nó
    if (loadingWidget != null) return loadingWidget!;

    // ngược lại dùng CircularProgressIndicator mặc định
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: const CircularProgressIndicator.adaptive(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      // Ủy quyền hoàn toàn cho widget cha thông qua onScrollNotification
      onNotification: onScrollNotification,
      child: Column(
        children: [
          GridView.builder(
            padding: _padding,
            gridDelegate: _gridDelegate,
            itemCount: itemCount,
            itemBuilder: itemBuilder,
            shrinkWrap: shrinkWrap,
            physics: physics,
          ),

          // Footer hiển thị loading indicator khi đang load thêm data
          _buildLoadingIndicator,
        ],
      ),
    );
  }
}
