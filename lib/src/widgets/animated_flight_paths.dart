import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../extensions.dart';
import '../flight/flight.dart';
import '../flight/flight_animations.dart';
import '../flight/flight_composition.dart';
import '../flight/flight_path_options.dart';
import '../flight/flight_schedule.dart';
import 'flight_paths_painter.dart';
import 'labels_layout/labels_layout.dart';
import 'map_svg.dart';

/// A widget to display animated flight paths.
class AnimatedFlightPaths extends StatefulWidget {
  const AnimatedFlightPaths({
    super.key,
    required this.flightSchedule,
    required this.controller,
    this.options = const FlightPathOptions(),
    this.debugShowOffsetOnTap = false,
    this.child = const MapSvg(),
  });

  /// The schedule with flights to be animated
  final FlightSchedule flightSchedule;

  /// Controls the flight path animations.
  final AnimationController controller;

  /// Describes how the flight paths should be drawn and animated.
  final FlightPathOptions options;

  /// The background for our flight path animations.
  final Widget child;

  /// Display a tooltip with the (x,y) coordinates upon click/tap.
  ///
  /// This is a convenience option that makes it easier to determine
  /// where a flight will depart [Flight.from] and arrive [Flight.to].
  ///
  /// Use the (x,y) coordinates to set:
  /// [Flight.from.offset]
  /// [Flight.to.offset]
  ///
  /// Fine-tune the red dot position with the arrow keys [↑ ↓ →  ←].
  final bool debugShowOffsetOnTap;

  @override
  State<AnimatedFlightPaths> createState() => _AnimatedFlightPathsState();
}

class _AnimatedFlightPathsState extends State<AnimatedFlightPaths>
    with WidgetsBindingObserver {
  final customPaintKey = GlobalKey();
  final keyboardListenerFocusNode = FocusNode();
  late List<FlightComposition> flightCompositions;
  Offset? dotOffset;
  Size? customPaintSize;

  @override
  void initState() {
    super.initState();
    _initCustomPaintSize();
    _createFlightCompositions();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return widget.debugShowOffsetOnTap
        ? _flightPathsStackWithInputListeners
        : _flightPathsStack;
  }

  Widget get _flightPathsStack => Stack(
        children: [
          _flightPathsCustomPaint,
          if (widget.options.showLabels) _labelsLayout,
          if (widget.debugShowOffsetOnTap && dotOffset != null) ...[
            _tapPositionDot,
            _tapPositionText,
          ],
        ],
      );

  Widget get _flightPathsStackWithInputListeners => KeyboardListener(
        focusNode: keyboardListenerFocusNode,
        onKeyEvent: _onKey,
        child: GestureDetector(
          onTapUp: (details) {
            if (widget.debugShowOffsetOnTap) {
              setState(() => dotOffset = details.localPosition);
            }
          },
          child: _flightPathsStack,
        ),
      );

  Widget get _flightPathsCustomPaint => ClipRect(
        child: CustomPaint(
          key: customPaintKey,
          foregroundPainter: FlightPathsPainter(
            flightCompositions: flightCompositions,
            options: widget.options,
            controller: widget.controller,
          ),
          child: widget.child,
        ),
      );

  Widget get _labelsLayout => SizedBox(
        width: customPaintSize != null ? customPaintSize!.width : 0,
        height: customPaintSize != null ? customPaintSize!.height : 0,
        child: LabelsLayout(
          flightComps: flightCompositions,
          options: widget.options,
          controller: widget.controller,
        ),
      );

  Widget get _tapPositionDot {
    const diameter = 8.0;
    return Positioned(
      top: dotOffset!.dy - (diameter / 2),
      left: dotOffset!.dx - (diameter / 2),
      child: Container(
        width: diameter,
        height: diameter,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
      ),
    );
  }

  Widget get _tapPositionText {
    if (customPaintSize == null) return const SizedBox();
    const width = 150.0;
    const height = 50.0;
    final x = (dotOffset!.dx / customPaintSize!.width) * 100;
    final y = (dotOffset!.dy / customPaintSize!.height) * 100;
    return Positioned(
      top: (dotOffset!.dy > customPaintSize!.height / 2)
          ? dotOffset!.dy - height
          : dotOffset!.dy,
      left: (dotOffset!.dx > customPaintSize!.width / 2)
          ? dotOffset!.dx - width
          : dotOffset!.dx,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          border: Border.all(width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  void _createFlightCompositions() {
    flightCompositions = widget.flightSchedule.flights.foldIndexed(
      <FlightComposition>[],
      (flightIndex, flightCompositions, flight) {
        final flightAnimations = FlightAnimations.fromFlightSchedule(
          flight: flight,
          schedule: widget.flightSchedule,
          options: widget.options,
          controller: widget.controller,
        );
        return flightCompositions
          ..add(FlightComposition(flight, flightAnimations));
      },
    );
  }

  void _onKey(KeyEvent event) {
    if (event is KeyUpEvent || event is KeyRepeatEvent) {
      return switch (event.logicalKey.keyLabel) {
        'Arrow Up' => _incrementDotOffset(const Offset(0, -1)),
        'Arrow Down' => _incrementDotOffset(const Offset(0, 1)),
        'Arrow Left' => _incrementDotOffset(const Offset(-1, 0)),
        'Arrow Right' => _incrementDotOffset(const Offset(1, 0)),
        _ => false
      };
    }
  }

  void _incrementDotOffset(Offset increment) {
    if (dotOffset == null) return;
    setState(() {
      dotOffset = (dotOffset! + increment).clampToSize(customPaintSize!);
    });
  }

  void _initCustomPaintSize() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => setState(() {
        customPaintSize = customPaintKey.currentContext?.size;
        dotOffset = null;
      }),
    );
  }

  @override
  void didChangeMetrics() => _initCustomPaintSize();

  @override
  void didUpdateWidget(AnimatedFlightPaths oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options != oldWidget.options) _createFlightCompositions();
    _initCustomPaintSize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
