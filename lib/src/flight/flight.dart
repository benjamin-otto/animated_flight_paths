import 'flight_endpoint.dart';

/// Describes a flight to be animated.
class Flight {
  Flight({
    required this.from,
    required this.to,
    required this.departureTime,
    required this.arrivalTime,
  })  : assert(departureTime.isBefore(arrivalTime)),
        assert(from.offset != to.offset);

  /// The offset and label of our "from" endpoint.
  final FlightEndpoint from;

  /// The offset and label of our "to" endpoint.
  final FlightEndpoint to;

  /// The time at which our flight will depart.
  ///
  /// Must fall within the range specified by:
  ///
  /// [FlightSchedule.start]...[FlightSchedule.end]
  final DateTime departureTime;

  /// The time at which our flight will arrive.
  ///
  /// Must fall within the range specified by:
  ///
  /// [FlightSchedule.start]...[FlightSchedule.end]
  final DateTime arrivalTime;
}
