import 'package:flutter/material.dart';

import 'flight/flight.dart';
import 'flight/flight_schedule.dart';

double calcPathLength(Path path) => path
    .computeMetrics()
    .fold(0.0, (prevLength, pathMetric) => prevLength + pathMetric.length);

Path extractSubPath(Path path, double startLength, double endLength) {
  final subPath = Path();
  final metricsIterator = path.computeMetrics().iterator;
  var currentStartLength = 0.0;

  while (metricsIterator.moveNext()) {
    final metric = metricsIterator.current;
    final currentEndLength = currentStartLength + metric.length;

    final isFirstSegment =
        startLength >= currentStartLength && startLength <= currentEndLength;
    final isMiddleSegment =
        startLength < currentStartLength && endLength > currentEndLength;
    final isLastSegment = currentEndLength > endLength;

    if (isFirstSegment && isLastSegment) {
      final pathSegment = metric.extractPath(startLength, endLength);
      subPath.addPath(pathSegment, Offset.zero);
      break;
    } else if (isFirstSegment) {
      final pathSegment = metric.extractPath(startLength, metric.length);
      subPath.addPath(pathSegment, Offset.zero);
    } else if (isMiddleSegment) {
      final pathSegment = metric.extractPath(0, metric.length);
      subPath.addPath(pathSegment, Offset.zero);
    } else if (isLastSegment) {
      final remainingLength = endLength - currentStartLength;
      final pathSegment = metric.extractPath(0, remainingLength);
      subPath.addPath(pathSegment, Offset.zero);
      break;
    }

    currentStartLength = currentEndLength;
  }

  return subPath;
}

(double intervalBegin, double intervalEnd) calcFlightInterval(
  FlightSchedule schedule,
  Flight flight,
) {
  final FlightSchedule(:start, :end) = schedule;
  final Flight(:departureTime, :arrivalTime) = flight;
  final scheduleDuration = end.difference(start).inMilliseconds;
  final startToDepartDuration = departureTime.difference(start).inMilliseconds;
  final startToArriveDuration = arrivalTime.difference(start).inMilliseconds;
  final intervalBegin = startToDepartDuration / scheduleDuration;
  final intervalEnd = startToArriveDuration / scheduleDuration;
  return (intervalBegin, intervalEnd);
}
