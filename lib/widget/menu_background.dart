import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  bool? _tickerEnabled;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DottedWorldMapTimeline.duration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final animationsEnabled = !MediaQuery.disableAnimationsOf(context);
    final tickerEnabled = TickerMode.valuesOf(context).enabled;
    if (_animationsEnabled == animationsEnabled &&
        _tickerEnabled == tickerEnabled) {
      return;
    }

    _animationsEnabled = animationsEnabled;
    _tickerEnabled = tickerEnabled;
    if (!animationsEnabled) {
      _controller
        ..stop()
        ..value = DottedWorldMapTimeline.reducedMotionPhase;
    } else if (tickerEnabled) {
      _controller
        ..stop()
        ..value = DottedWorldMapTimeline.currentPhase
        ..repeat();
    } else {
      _controller.stop();
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
                key: const ValueKey('dotted-world-map-translation'),
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

class DottedWorldMapTimeline {
  static const Duration duration = Duration(seconds: 48);
  static const double reducedMotionPhase = 0.25;

  static double get currentPhase => phaseAt(
        SchedulerBinding.instance.currentFrameTimeStamp,
      );

  static double phaseAt(Duration elapsed) {
    final durationMicroseconds = duration.inMicroseconds;
    final elapsedInCycle = elapsed.inMicroseconds % durationMicroseconds;
    return elapsedInCycle / durationMicroseconds;
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
