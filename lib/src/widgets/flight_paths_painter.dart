import 'package:flutter/material.dart';

import '../flight/flight_composition.dart';
import '../flight/flight_path.dart';
import '../flight/flight_path_options.dart';
import '../helpers.dart';

class FlightPathsPainter extends CustomPainter {
  FlightPathsPainter({
    required this.flightCompositions,
    required this.options,
    required AnimationController controller,
  })  : fromPaint = Paint()
          ..color = options.fromEndpointColor
          ..style = PaintingStyle.fill,
        toPaint = Paint()
          ..color = options.toEndpointColor
          ..style = PaintingStyle.fill,
        flightPathPaint = Paint()
          ..color = options.flightPathColor
          ..strokeWidth = options.flightPathStrokeWidth
          ..style = PaintingStyle.stroke,
        super(repaint: controller);

  final List<FlightComposition> flightCompositions;
  final FlightPathOptions options;
  final Paint fromPaint;
  final Paint flightPathPaint;
  final Paint toPaint;
  late List<FlightPath> flightPaths;
  Size? canvasSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (canvasSize != size) {
      canvasSize = size;
      _createFlightPaths(canvasSize!);
    }

    _paintFlightPaths(canvas, size);
  }

  void _createFlightPaths(Size canvasSize) {
    flightPaths = flightCompositions.fold(
      <FlightPath>[],
      (flightPaths, flightComposition) => flightPaths
        ..add(FlightPath.sizedToCanvas(
          flight: flightComposition.flight,
          endpointRadius: options.endpointRadius,
          curveDepth: options.curveDepth,
          canvasSize: canvasSize,
        )),
    );
  }

  void _paintFlightPaths(Canvas canvas, Size canvasSize) {
    for (int i = 0; i < flightCompositions.length; i++) {
      final animations = flightCompositions[i].animations;
      final flightPath = flightPaths[i];
      final (fromAnimVal, toAnimVal) = options.endpointDotAlwaysVisible
          ? (1, 1)
          : (animations.fromVal, animations.toVal);
      final flightCurveSubPath = extractSubPath(
        flightPath.curvePath,
        flightPath.curvePathLength * animations.pathStartVal,
        flightPath.curvePathLength * animations.pathEndVal,
      );

      canvas.drawCircle(
        flightPath.fromOffset,
        options.endpointRadius * fromAnimVal,
        fromPaint,
      );
      canvas.drawPath(
        flightCurveSubPath,
        flightPathPaint,
      );
      canvas.drawCircle(
        flightPath.toOffset,
        options.endpointRadius * toAnimVal,
        toPaint,
      );
    }
  }

  @override
  bool shouldRepaint(FlightPathsPainter oldDelegate) =>
      flightCompositions != oldDelegate.flightCompositions ||
      options != oldDelegate.options;
}
