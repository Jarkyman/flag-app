import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../helper/dimensions.dart';
import 'background_image.dart';

class MenuBackground extends StatelessWidget {
  final Widget child;
  final bool showDottedWorldMap;

  const MenuBackground({
    super.key,
    required this.child,
    this.showDottedWorldMap = true,
  });

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      child: Stack(
        children: [
          if (showDottedWorldMap)
            const Positioned.fill(child: _AnimatedDottedWorldMap()),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _AnimatedDottedWorldMap extends StatefulWidget {
  const _AnimatedDottedWorldMap();

  @override
  State<_AnimatedDottedWorldMap> createState() =>
      _AnimatedDottedWorldMapState();
}

class _AnimatedDottedWorldMapState extends State<_AnimatedDottedWorldMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool? _animationsEnabled;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 48),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final animationsEnabled = !MediaQuery.disableAnimationsOf(context);
    if (_animationsEnabled == animationsEnabled) return;

    _animationsEnabled = animationsEnabled;
    if (animationsEnabled) {
      _controller.repeat();
    } else {
      _controller
        ..stop()
        ..value = 0.25;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapHeight = Dimensions.screenHeight * 1.32;
    final mapWidth = mapHeight * 1.5;

    return IgnorePointer(
      child: ClipRect(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(-mapWidth * _controller.value, 0),
                child: child,
              );
            },
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              minWidth: mapWidth * 2,
              maxWidth: mapWidth * 2,
              minHeight: mapHeight,
              maxHeight: mapHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    width: mapWidth,
                    height: mapHeight,
                    child: _DottedWorldMapImage(
                      width: mapWidth,
                      height: mapHeight,
                    ),
                  ),
                  Positioned(
                    left: mapWidth,
                    width: mapWidth,
                    height: mapHeight,
                    child: _DottedWorldMapImage(
                      width: mapWidth,
                      height: mapHeight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DottedWorldMapImage extends StatelessWidget {
  final double width;
  final double height;

  const _DottedWorldMapImage({
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.13,
      child: SvgPicture.asset(
        'assets/image/dotted_world_map.svg',
        width: width,
        height: height,
        fit: BoxFit.fill,
      ),
    );
  }
}
