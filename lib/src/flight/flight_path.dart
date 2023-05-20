import 'dart:math' as math;
import 'dart:ui';

import '../extensions.dart';
import '../helpers.dart';
import 'flight.dart';

class FlightPath {
  FlightPath({
    required this.fromOffset,
    required this.curvePath,
    required this.toOffset,
  });

  factory FlightPath.sizedToCanvas({
    required Flight flight,
    required double endpointRadius,
    required double curveDepth,
    required Size canvasSize,
  }) {
    Offset from = flight.from.offset.multiplyBySize(canvasSize);
    Offset to = flight.to.offset.multiplyBySize(canvasSize);
    Offset pathControl = _calcControlPoint(
      from,
      to,
      curveDepth,
      canvasSize.width,
    ).clampToSize(canvasSize);
    Offset pathFrom = _calcCurveEndpoint(from, pathControl, endpointRadius);
    Offset pathTo = _calcCurveEndpoint(to, pathControl, endpointRadius);
    Path curvePath = _createCurvePath(pathFrom, pathControl, pathTo);

    return FlightPath(
      fromOffset: from,
      curvePath: curvePath,
      toOffset: to,
    );
  }

  final Offset fromOffset;
  final Path curvePath;
  final Offset toOffset;

  double? _curvePathLength;

  double get curvePathLength {
    if (_curvePathLength != null) return _curvePathLength!;
    _curvePathLength = calcPathLength(curvePath);
    return _curvePathLength!;
  }
}

/// The Bezier curve's endpoints need to be offset by the from/to endpoint
/// radius, else the curve will paint over the endpoints.
///
/// [Formula](https://math.stackexchange.com/questions/175896/finding-a-point-along-a-line-a-certain-distance-away-from-another-point)
Offset _calcCurveEndpoint(
  Offset endpoint,
  Offset controlPoint,
  double endpointRadius,
) {
  num dxSquared = math.pow(controlPoint.dx - endpoint.dx, 2);
  num dySquared = math.pow(controlPoint.dy - endpoint.dy, 2);
  double distance = math.sqrt(dxSquared + dySquared);
  double t = endpointRadius / distance;
  double x = ((1 - t) * endpoint.dx) + (t * controlPoint.dx);
  double y = ((1 - t) * endpoint.dy) + (t * controlPoint.dy);
  return Offset(x, y);
}

/// The control point towards which the Bezier curve will be curving.
///
/// [Formula](https://math.stackexchange.com/questions/1842614/find-third-coordinate-for-a-right-triangle-with-45degree-angles)
Offset _calcControlPoint(
  Offset from,
  Offset to,
  double curveDepth,
  double canvasWidth,
) {
  Offset midPoint = (from + to) / 2;
  Offset diff = to - from;
  Offset rotated90Point = Offset(-diff.dy, diff.dx) / 2;
  Offset controlPointPlus = midPoint + (rotated90Point * curveDepth);
  Offset controlPointMinus = midPoint - (rotated90Point * curveDepth);

  // Exactly vertical flights will curve towards the center
  if (from.dx == to.dx) {
    double horizontalCenter = canvasWidth / 2;
    double diffPlusDx = (controlPointPlus.dx - horizontalCenter).abs();
    double diffMinusDx = (controlPointMinus.dx - horizontalCenter).abs();
    return (diffPlusDx < diffMinusDx) ? controlPointPlus : controlPointMinus;
  }

  // Curve towards the higher point on the map (looks better)
  return (controlPointPlus.dy < controlPointMinus.dy)
      ? controlPointPlus
      : controlPointMinus;
}

/// Create the Bezier curve for the flight path.
Path _createCurvePath(
  Offset fromOffset,
  Offset controlPointOffset,
  Offset toOffset,
) {
  return Path()
    ..moveToFromOffset(fromOffset)
    ..quadraticBezierToFromOffsets(controlPointOffset, toOffset);
}
