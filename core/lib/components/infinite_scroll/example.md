# Infinite Scroll Grid

Pure Flutter components for paginated grid UIs with scroll-triggered load-more.

**Module path:** `core/lib/components/infinite_scroll/`

| File | Symbol | Role |
|------|--------|------|
| `infinite_scroll.dart` | `AdvancedInfiniteGridView<T>` | Grid layout + built-in `NotificationListener` + optional loading footer |
| `mixin/infinite_scroll_mixin.dart` | `InfiniteScrollNotificationHandler` | Scroll math + guard clauses; **no BLoC import** — UI wires BLoC via getters |

> **Agent note:** `InfiniteScrollContract` in older drafts does **not** exist. Use `InfiniteScrollNotificationHandler` only.

---

## When to use this module

| Scenario | Use this module? |
|----------|------------------|
| Grid is the **main scrollable** inside `Scaffold.body` (bounded height) | **Yes** — `AdvancedInfiniteGridView` + mixin |
| Grid is **nested** inside parent `SingleChildScrollView` (`shrinkWrap: true`) | **No** — parent owns scroll metrics; use app-level `InfiniteScrollGridView` in `lib/common/widgets/infinite_scroll/` instead |
| Load-more on **scroll end** near bottom (pixel threshold) | App common widget pattern |
| Load-more while scrolling past **80%** of extent | This module (`threshold` on mixin) |

---

## Architecture

```text
StatefulWidget (Screen)
  └─ with InfiniteScrollNotificationHandler
       ├─ isDataLoading      ← from BLoC state
       ├─ hasMoreDataToLoad  ← from BLoC state
       ├─ onTriggerLoadMore() → bloc.add(...)
       └─ handleScrollNotification() → passed to grid

AdvancedInfiniteGridView
  └─ NotificationListener(onNotification: handleScrollNotification)
       └─ Column
            ├─ Expanded → GridView.builder
            └─ loading footer (if showLoadingIndicator)
```

**Responsibility split**

- **Mixin:** scroll detection + guards (`!hasMoreDataToLoad`, `!isDataLoading`).
- **Grid widget:** layout only; delegates every scroll decision to `onScrollNotification`.
- **Screen / feature:** BLoC, `itemBuilder`, empty/error/loading shells.

---

## API reference

### `InfiniteScrollNotificationHandler`

```dart
mixin InfiniteScrollNotificationHandler {
  bool get isDataLoading;
  bool get hasMoreDataToLoad;
  void onTriggerLoadMore();

  bool handleScrollNotification(
    ScrollNotification notification, {
    double threshold = 0.8, // fraction of maxScrollExtent
  });
}
```

- Triggers on `ScrollUpdateNotification` (fires while scrolling, not only on release).
- Fires when `pixels >= maxScrollExtent * threshold`.
- Returns `false` so notifications can bubble.

### `AdvancedInfiniteGridView<T>`

| Parameter | Required | Description |
|-----------|----------|-------------|
| `items` | yes | Data list (length drives `itemCount`) |
| `itemBuilder` | yes | `(context, index) → Widget` — read `items[index]` inside |
| `gridDelegate` | yes | e.g. `SliverGridDelegateWithFixedCrossAxisCount` |
| `onScrollNotification` | yes | Usually `handleScrollNotification` from mixin |
| `showLoadingIndicator` | yes | Shows footer loader when true |
| `padding` | no | Grid padding |
| `loadingWidget` | no | Custom footer; default is adaptive `CircularProgressIndicator` |

**Requires** a bounded max height (typically `Scaffold` + `Expanded` is handled inside the widget).

---

## Imports

Not exported from `core.dart` yet — import explicitly:

```dart
import 'package:flutter_supper_app_core/components/infinite_scroll/infinite_scroll.dart';
import 'package:flutter_supper_app_core/components/infinite_scroll/mixin/infinite_scroll_mixin.dart';
```

---

## Minimal example (standalone screen)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_supper_app_core/components/infinite_scroll/infinite_scroll.dart';
import 'package:flutter_supper_app_core/components/infinite_scroll/mixin/infinite_scroll_mixin.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen>
    with InfiniteScrollNotificationHandler {
  ProductBloc get _bloc => context.read<ProductBloc>();

  @override
  bool get isDataLoading =>
      _bloc.state.status == ProductStatus.loadingMore;

  @override
  bool get hasMoreDataToLoad => _bloc.state.hasMore;

  @override
  void onTriggerLoadMore() {
    _bloc.add(const FetchNextProductPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catalog')),
      body: BlocBuilder<ProductBloc, ProductState>(
        buildWhen: (prev, curr) =>
            prev.products != curr.products || prev.status != curr.status,
        builder: (context, state) {
          return AdvancedInfiniteGridView<Product>(
            items: state.products,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: 200,
            ),
            showLoadingIndicator: state.status == ProductStatus.loadingMore,
            onScrollNotification: handleScrollNotification,
            itemBuilder: (context, index) {
              final product = state.products[index];
              return ProductCard(product: product);
            },
          );
        },
      ),
    );
  }
}
```

---

## Checklist (implementation)

1. Screen `State` mixes in `InfiniteScrollNotificationHandler`.
2. Override three members from **current** BLoC state (no `setState` in mixin).
3. Pass `onScrollNotification: handleScrollNotification` into the grid.
4. Set `showLoadingIndicator` from BLoC when loading more.
5. Wrap with `BlocBuilder` / `buildWhen` for list + status changes.
6. Confirm layout: body must allow `Expanded` inside the grid (full-screen catalog pattern).

---

## Pitfalls

| Mistake | Symptom | Fix |
|---------|---------|-----|
| Grid inside unbounded `Column` without height | Layout exception | Put screen in `Scaffold.body` or give explicit height |
| Nested in `SingleChildScrollView` | Load-more never fires or wrong metrics | Use common `InfiniteScrollGridView` + parent `NotificationListener` |
| `hasMoreDataToLoad` always `true` | Duplicate API calls | Map `isEnd` / `hasMore` from BLoC correctly |
| `isDataLoading` false during load-more | Double fetch | Include `loadingMore` in getter |
| Expect scroll-end only | Load-more feels early/late | Adjust `threshold` in `handleScrollNotification(..., threshold: 0.9)` |

---

## Related code in this repo

- **Kho Phim (nested scroll):** `lib/features/kho_phim/presentation/widget/kho_phim_infinite_gridview_widget.dart` — parent `SingleChildScrollView` + `GlobalKey.handleScrollEnd`; not this core module.
- **Reference integration (if adopted):** mirror mixin getters to `isLoadingMore` / `isEnd` on feature BLoC.

---

## Agent quick prompt

> Integrate infinite scroll grid from `core/lib/components/infinite_scroll/`: use `InfiniteScrollNotificationHandler` on screen State, `AdvancedInfiniteGridView` with `onScrollNotification: handleScrollNotification`, wire `isDataLoading` / `hasMoreDataToLoad` / `onTriggerLoadMore` to the feature BLoC. Do not use for nested `SingleChildScrollView` grids.
