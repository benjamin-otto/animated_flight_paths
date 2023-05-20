import 'package:flutter/material.dart';

import '../helpers.dart';
import 'flight.dart';
import 'flight_path_options.dart';
import 'flight_schedule.dart';

class FlightAnimations {
  const FlightAnimations({
    required this.fromDrawAnim,
    required this.fromClearAnim,
    required this.pathStartAnim,
    required this.pathEndAnim,
    required this.toDrawAnim,
    required this.toClearAnim,
  });

  factory FlightAnimations.fromFlightSchedule({
    required Flight flight,
    required FlightSchedule schedule,
    required FlightPathOptions options,
    required AnimationController controller,
  }) {
    final (intervalBegin, intervalEnd) = calcFlightInterval(schedule, flight);
    final intervalLength = intervalEnd - intervalBegin;
    final intervalMidpoint = intervalBegin + intervalLength / 2;
    final endpointLength = (intervalLength / 2) * options.endpointWeight;

    final fromDrawAnim = CurvedAnimation(
      parent: controller,
      curve: Interval(
        intervalBegin,
        intervalBegin + endpointLength,
        curve: options.fromEndpointCurve,
      ),
    );
    final fromClearAnim = CurvedAnimation(
      parent: controller,
      curve: Interval(
        intervalMidpoint,
        intervalMidpoint + endpointLength,
        curve: options.fromEndpointCurve,
      ),
    );
    final pathStartAnim = options.keepFlightPathsVisible
        ? ConstantTween<double>(0).animate(controller)
        : CurvedAnimation(
            parent: controller,
            curve: Interval(
              intervalMidpoint,
              intervalEnd - endpointLength,
              curve: options.flightPathCurve,
            ),
          );
    final pathEndAnim = CurvedAnimation(
      parent: controller,
      curve: Interval(
        intervalBegin + endpointLength,
        intervalMidpoint,
        curve: options.flightPathCurve,
      ),
    );
    final toDrawAnim = CurvedAnimation(
      parent: controller,
      curve: Interval(
        intervalMidpoint - endpointLength,
        intervalMidpoint,
        curve: options.fromEndpointCurve,
      ),
    );
    final toClearAnim = CurvedAnimation(
      parent: controller,
      curve: Interval(
        intervalEnd - endpointLength,
        intervalEnd,
        curve: options.fromEndpointCurve,
      ),
    );

    return FlightAnimations(
      fromDrawAnim: fromDrawAnim,
      fromClearAnim: fromClearAnim,
      pathStartAnim: pathStartAnim,
      pathEndAnim: pathEndAnim,
      toDrawAnim: toDrawAnim,
      toClearAnim: toClearAnim,
    );
  }

  final Animation<double> fromDrawAnim;
  final Animation<double> fromClearAnim;
  final Animation<double> pathStartAnim;
  final Animation<double> pathEndAnim;
  final Animation<double> toDrawAnim;
  final Animation<double> toClearAnim;

  double get fromVal => fromDrawAnim.value - fromClearAnim.value;

  double get pathStartVal => pathStartAnim.value;

  double get pathEndVal => pathEndAnim.value;

  double get toVal => toDrawAnim.value - toClearAnim.value;
}
