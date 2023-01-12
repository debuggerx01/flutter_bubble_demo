import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bubble_demo/global.dart';
import 'package:rect_getter/rect_getter.dart';

/// 被提醒元素在哪个区域的枚举
enum PositionAlignment {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

const kVerticalSpacing = 5;
const kHorizontalSpacing = 30;

extension PositionAlignmentExt on PositionAlignment {
  bool get isTop =>
      [PositionAlignment.topLeft, PositionAlignment.topRight].contains(this);

  bool get isBottom => [
        PositionAlignment.bottomLeft,
        PositionAlignment.bottomRight
      ].contains(this);

  bool get isLeft =>
      [PositionAlignment.topLeft, PositionAlignment.bottomLeft].contains(this);

  bool get isRight => [
        PositionAlignment.topRight,
        PositionAlignment.bottomRight
      ].contains(this);
}

class NewFeatureBubble extends StatefulWidget {
  const NewFeatureBubble({
    Key? key,
    required this.featureId,
    required this.featureDescription,
    required this.child,
    this.dynamicFollow = false,
    this.verticalSpacing,
    this.horizontalSpacing,
    this.forceAlignment,
    this.hideWhenDialogShown = true,
  }) : super(key: key);

  /// 被提醒的组件
  final Widget child;

  /// 新功能的id，用于标记是否已经显示过
  final String featureId;

  /// 新功能的描述信息
  final String featureDescription;

  /// 动态跟随可能会有性能问题
  final bool dynamicFollow;

  /// 气泡和组件间的垂直间距
  final double? verticalSpacing;

  /// 气泡和组件的横向偏移
  final double? horizontalSpacing;

  /// 强制设置被提醒组件在哪个区域，从而控制气泡的显示逻辑
  final PositionAlignment? forceAlignment;

  /// 当页面中有弹窗显示时隐藏气泡的显示，从而避免遮挡
  final bool hideWhenDialogShown;

  @override
  State<NewFeatureBubble> createState() => _NewFeatureBubbleState();
}

class _NewFeatureBubbleState extends State<NewFeatureBubble> {
  late RectGetter child;
  OverlayEntry? entry;

  double? left;
  double? right;
  double? top;
  double? bottom;

  Ticker? _ticker;
  Rect? _preRect;

  bool hidden = false;

  @override
  void initState() {
    NewFeatureRouteObserver.instance.addPageChangedCallback(() {
      /// 页面路由切换，关闭弹窗并保存标记
      _stopTicker();
      entry?.remove();
      entry?.dispose();
      entry = null;

      G[widget.featureId] = true;
    });

    NewFeatureRouteObserver.instance
        .addTopIsDialogChangedCallback((topIsDialog) {
      /// 有弹窗的时候隐藏气泡
      if (mounted) {
        setState(() {
          hidden = topIsDialog;
        });
      }
      entry?.markNeedsBuild();
    });

    /// 如果已经显示过气泡，再次进入页面就不再显示
    if (G[widget.featureId] == true) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _rebuildBubble();
      if (widget.dynamicFollow) {
        /// 如果开启动态跟随，则启动一个触发器不断触发气泡重绘
        /// _rebuildBubble方法内部会检查被标记组件的rect是否发生了变化，从而决定是否更新气泡位置
        _ticker = Ticker((elapsed) {
          _rebuildBubble();
        });
        _ticker?.start();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    child = RectGetter.defaultKey(child: widget.child);
    return child;
  }

  void _stopTicker() {
    _ticker?.stop(canceled: true);
    _ticker?.dispose();
  }

  void _rebuildBubble() {
    var rect = child.getRect();
    if (rect != null) {
      if (_preRect == rect) {
        /// 如果组件的位置大小沒有发生变化，则避免重绘
        return;
      }
      _preRect = rect;
      var screenSize = MediaQuery.of(context).size;
      var screenCenter = screenSize.center(Offset.zero);
      late PositionAlignment alignment;
      if (widget.forceAlignment != null) {
        /// 如果设置了强制区域，则使用该设置
        alignment = widget.forceAlignment!;
      } else {
        /// 否则根据组件的rect和屏幕尺寸关系计算得出所在区域
        if (rect.center.dx < screenCenter.dx) {
          alignment = rect.center.dy < screenCenter.dy
              ? PositionAlignment.topLeft
              : PositionAlignment.bottomLeft;
        } else {
          alignment = rect.center.dy < screenCenter.dy
              ? PositionAlignment.topRight
              : PositionAlignment.bottomRight;
        }
      }

      var verticalSpacing = widget.verticalSpacing ?? kVerticalSpacing;
      var horizontalSpacing = widget.horizontalSpacing ?? kHorizontalSpacing;

      /// 根据所在区域不同，计算气泡的位置
      top = alignment.isTop ? (rect.bottom + verticalSpacing) : null;
      bottom = alignment.isBottom
          ? (screenSize.height - rect.top + verticalSpacing)
          : null;
      left = alignment.isLeft ? (rect.center.dx - horizontalSpacing) : null;
      right = alignment.isRight
          ? (screenSize.width - rect.center.dx - horizontalSpacing)
          : null;
    }

    /// 如果entry为空则创建，并插入Overlay中
    if (entry == null) {
      entry = OverlayEntry(
        /// 每次执行markNeedsBuild()后会重新执行这个builder，从而实现气泡的更新
        /// 只要在此之前更新好气泡的位置值和是否需要隐藏即可
        builder: (context) => widget.hideWhenDialogShown && hidden
            ? const SizedBox()
            : Positioned(
                left: left,
                right: right,
                top: top,
                bottom: bottom,
                child: Material(
                  child: Container(
                    color: Colors.amber,
                    child: Text(
                      widget.featureDescription,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
      );
      Overlay.of(context)?.insert(entry!);
    } else {
      /// entry存在时说明气泡已经显示，只要将它标记为需要重绘，下一帧就会执行上面的builder
      entry!.markNeedsBuild();
    }
  }
}

class NewFeatureRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  NewFeatureRouteObserver._();

  static final NewFeatureRouteObserver _instance = NewFeatureRouteObserver._();

  static NewFeatureRouteObserver get instance => _instance;

  /// __current和_currentRouteName都是调试用的，可以删掉
  late Route __current;

  String get _currentRouteName => __current is MaterialPageRoute
      ? (__current as MaterialPageRoute).builder.toString()
      : '';

  bool topIsDialog = false;

  final List<VoidCallback> _pageChangedCallbacks = [];

  final List<ValueChanged<bool>> _topIsDialogChangedCallbacks = [];

  /// 添加页面路由变化时的回调
  addPageChangedCallback(VoidCallback callback) {
    _pageChangedCallbacks.add(callback);
  }

  /// 添加弹窗显示隐藏的回调
  addTopIsDialogChangedCallback(ValueChanged<bool> callback) {
    _topIsDialogChangedCallbacks.add(callback);
  }

  set _current(route) {
    __current = route;
    print(_currentRouteName);
    for (var callback in _pageChangedCallbacks) {
      callback.call();
    }
    _pageChangedCallbacks.clear();
  }

  /// 常见的route可以分为PageRoute和DialogRoute两大类
  /// 利用订阅，判断得出页面是否变化、弹窗时候显示隐藏

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute is PageRoute) {
      if (route is RawDialogRoute) {
        for (var callback in _topIsDialogChangedCallbacks) {
          callback.call(false);
        }
        return;
      }
      _current = previousRoute;
    }
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route is RawDialogRoute) {
      for (var callback in _topIsDialogChangedCallbacks) {
        callback.call(true);
      }
    } else if (route is PageRoute) {
      _current = route;
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute is PageRoute) {
      _current = newRoute;
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    if (route is PageRoute) {
      _current = route;
    }
    super.didRemove(route, previousRoute);
  }
}
