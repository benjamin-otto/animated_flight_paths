import 'package:flutter/material.dart';

/// Options for how to draw and animate the flight paths.
class FlightPathOptions {
  const FlightPathOptions({
    this.showLabels = true,
    this.fromEndpointColor = Colors.yellow,
    this.flightPathColor = Colors.yellow,
    this.toEndpointColor = Colors.yellow,
    this.fromEndpointCurve = Curves.easeInOutSine,
    this.flightPathCurve = Curves.easeInOutSine,
    this.toEndpointCurve = Curves.easeInOutSine,
    this.flightPathStrokeWidth = 2,
    this.endpointRadius = 5,
    this.endpointToLabelSpacing = 12,
    this.endpointDotAlwaysVisible = false,
    this.endpointLabelAlwaysVisible = false,
    this.keepFlightPathsVisible = false,
    this.curveDepth = 0.5,
    this.endpointWeight = 0.1,
  })  : assert(flightPathStrokeWidth > 0),
        assert(endpointRadius >= 0),
        assert(endpointToLabelSpacing >= 0),
        assert(0 <= curveDepth && curveDepth <= 1),
        assert(0 <= endpointWeight && endpointWeight < 0.5);

  /// Show the labels set in [FlightEndpoint.label]
  final bool showLabels;

  /// The color of the "from" circular endpoint.
  final Color fromEndpointColor;

  /// The color of the curved flight path.
  final Color flightPathColor;

  /// The color of the "to" circular endpoint.
  final Color toEndpointColor;

  /// Curve for drawing and clearing the "from" endpoint dot and label.
  final Curve fromEndpointCurve;

  /// Curve for drawing and clearing the flight path Bezier curve path.
  final Curve flightPathCurve;

  /// Curve for drawing and clearing the "to" endpoint dot and label.
  final Curve toEndpointCurve;

  /// The width of the flight path curve.
  final double flightPathStrokeWidth;

  /// The radius of the "from" and "to" circular endpoints.
  final double endpointRadius;

  /// The distance between the circular endpoints the their labels.
  final double endpointToLabelSpacing;

  /// Keep the endpoint dot visible on the map at all times.
  final bool endpointDotAlwaysVisible;

  /// Keep the endpoint label visible on the map at all times.
  ///
  /// [showLabels] must also be set to true.
  final bool endpointLabelAlwaysVisible;

  // Keep flight paths visible after drawn.
  final bool keepFlightPathsVisible;

  /// The depth of the flight path curve.
  ///
  /// Must fall in the range [0, 1].
  ///
  /// If set to zero the flight path will be a straight line.
  final double curveDepth;

  /// The percentage of the flight animation for which the
  /// endpoints will be drawn and cleared.
  ///
  /// For example:
  /// If [endpointWeight] == 0.1
  /// then the "from" endpoint will animate for the first 10% of the interval
  /// and the "to" endpoint will animate for the last 10% of the interval.
  ///
  /// This value must be between [0, 0.5).
  final double endpointWeight;
}
