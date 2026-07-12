import 'package:flutter/material.dart';

import '../helper/dimensions.dart';

class AppSwipeDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeDown;
  final double? minimumHorizontalDistance;
  final double? minimumVerticalDistance;

  const AppSwipeDetector({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeDown,
    this.minimumHorizontalDistance,
    this.minimumVerticalDistance,
  })  : assert(
          minimumHorizontalDistance == null || minimumHorizontalDistance > 0,
        ),
        assert(
          minimumVerticalDistance == null || minimumVerticalDistance > 0,
        );

  @override
  State<AppSwipeDetector> createState() => _AppSwipeDetectorState();
}

class _AppSwipeDetectorState extends State<AppSwipeDetector> {
  int? _activePointer;
  Offset? _startPosition;

  void _handlePointerDown(PointerDownEvent event) {
    if (_activePointer != null) return;

    _activePointer = event.pointer;
    _startPosition = event.position;
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (event.pointer != _activePointer || _startPosition == null) return;

    final offset = event.position - _startPosition!;
    _resetGesture();

    if (offset.dx.abs() > offset.dy.abs()) {
      final minimumDistance =
          widget.minimumHorizontalDistance ?? Dimensions.width45;
      if (offset.dx.abs() < minimumDistance) return;

      if (offset.dx < 0) {
        widget.onSwipeLeft?.call();
      } else {
        widget.onSwipeRight?.call();
      }
      return;
    }

    final minimumDistance =
        widget.minimumVerticalDistance ?? Dimensions.height45;
    if (offset.dy >= minimumDistance) {
      widget.onSwipeDown?.call();
    }
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (event.pointer == _activePointer) {
      _resetGesture();
    }
  }

  void _resetGesture() {
    _activePointer = null;
    _startPosition = null;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: widget.child,
    );
  }
}
