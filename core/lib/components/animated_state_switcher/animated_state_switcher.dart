import 'package:flutter/material.dart';

/// [AnimationStateSwitcher] điều hướng việc chuyển đổi mượt mà giữa các Widget State.
/// Sử dụng kiến trúc Implicit Animation để đảm bảo tính đóng gói (Encapsulation)
/// và tự động giải phóng bộ nhớ (Memory Management).
class AnimationStateSwitcher extends StatelessWidget {
  const AnimationStateSwitcher({
    required this.child,
    required this.valueKey,
    this.duration = const Duration(milliseconds: 300),
    this.switchInCurve = Curves.easeInOut,
    this.switchOutCurve = Curves.easeInOut,
    super.key,
  });

  final Widget child;
  final Object valueKey; // Định danh duy nhất cho từng trạng thái UI
  final Duration duration;
  final Curve switchInCurve;
  final Curve switchOutCurve;

  @override
  Widget build(BuildContext context) {
    // Sử dụng AnimatedSwitcher gốc của Flutter đã được tối ưu ở tầng Engine C++
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: switchInCurve,
      switchOutCurve: switchOutCurve,
      // Sử dụng RepaintBoundary để tách biệt lớp vẽ của hiệu ứng
      // tránh ảnh hưởng đến toàn bộ các Widget cha bên ngoài.
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // ...previousChildren.map((e) => RepaintBoundary(child: e)),
            if (currentChild != null) RepaintBoundary(child: currentChild),
          ],
        );
      },

      //Sử dụng các Widget Animation chuyên biệt (như FadeTransition)
      // thay vì dùng AnimatedBuilder lồng bừa bãi.
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },

      // Khóa cốt lõi nằm ở đây: Bọc child bằng một KeyedSubtree
      // để ép Flutter Element Tree phải nhận diện sự khác biệt.
      // ValueKey<Object> sẽ tự động gọi hàm hashCode và toán tử == của Object
      child: KeyedSubtree(
        key: ValueKey<Object>(valueKey),
        child: child,
      ),
    );
  }
}
