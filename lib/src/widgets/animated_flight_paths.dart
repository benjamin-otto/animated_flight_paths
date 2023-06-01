import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  late List<FlightComposition> _flightCompositions;
  final _keyboardListenerFocusNode = FocusNode();
  Offset? _dotOffset;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _createFlightCompositions();
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
          if (widget.debugShowOffsetOnTap && _dotOffset != null) ...[
            _tapPositionDot,
            _tapPositionText,
          ],
        ],
      );

  Widget get _flightPathsStackWithInputListeners => GestureDetector(
        onTapUp: (details) {
          if (!widget.debugShowOffsetOnTap) return;
          if (!_keyboardListenerFocusNode.hasFocus) {
            _keyboardListenerFocusNode.requestFocus();
          }
          setState(() => _dotOffset = details.localPosition);
        },
        child: FocusScope(
          child: KeyboardListener(
            focusNode: _keyboardListenerFocusNode,
            onKeyEvent: _onKey,
            child: _flightPathsStack,
          ),
        ),
      );

  Widget get _flightPathsCustomPaint => ClipRect(
        child: CustomPaint(
          foregroundPainter: FlightPathsPainter(
            flightCompositions: _flightCompositions,
            options: widget.options,
            controller: widget.controller,
          ),
          child: widget.child,
        ),
      );

  Widget get _labelsLayout => Positioned.fill(
        child: LabelsLayout(
          flightComps: _flightCompositions,
          options: widget.options,
          controller: widget.controller,
        ),
      );

  Widget get _tapPositionDot {
    const diameter = 8.0;
    return Positioned(
      top: _dotOffset!.dy - (diameter / 2),
      left: _dotOffset!.dx - (diameter / 2),
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
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (_, constraints) {
          const width = 150.0;
          const height = 50.0;
          final x = (_dotOffset!.dx / constraints.maxWidth) * 100;
          final y = (_dotOffset!.dy / constraints.maxHeight) * 100;
          final dx = _dotOffset!.dx > constraints.maxWidth / 2
              ? _dotOffset!.dx - width
              : _dotOffset!.dx;
          final dy = _dotOffset!.dy > constraints.maxHeight / 2
              ? _dotOffset!.dy - height
              : _dotOffset!.dy;
          return Align(
            alignment: Alignment.topLeft,
            child: Transform.translate(
              offset: Offset(dx, dy),
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
            ),
          );
        },
      ),
    );
  }

  void _createFlightCompositions() {
    _flightCompositions = widget.flightSchedule.flights.foldIndexed(
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
        _ => {}
      };
    }
  }

  void _incrementDotOffset(Offset increment) {
    if (_dotOffset != null) {
      setState(() => _dotOffset = _dotOffset! + increment);
    }
  }

  void _resetDotOffset() {
    if (mounted && _dotOffset != null) {
      setState(() => _dotOffset = null);
    }
  }

  @override
  void didChangeMetrics() => _resetDotOffset();

  @override
  void didUpdateWidget(AnimatedFlightPaths oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options != oldWidget.options) _createFlightCompositions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
