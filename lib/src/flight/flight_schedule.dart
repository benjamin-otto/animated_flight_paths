import 'flight.dart';

/// Describes the start and end of the flying period
/// as well as the flights that will occur in that time range.
class FlightSchedule {
  FlightSchedule({
    required this.start,
    required this.end,
    required this.flights,
  })  : assert(start.isBefore(end)),
        assert(flightsWithinSchedule(start, end, flights));

  /// The start of the flight schedule.
  ///
  /// All flights must depart at or after this time.
  final DateTime start;

  /// The end of the flight schedule.
  ///
  /// All flights must arrive at or before this time.
  final DateTime end;

  /// The flights occurring between [start] and [end] to be animated.
  final List<Flight> flights;

  /// Check if a list of flights occurs within the schedule range.
  static bool flightsWithinSchedule(
    DateTime start,
    DateTime end,
    List<Flight> flights,
  ) {
    return flights.every((flight) {
      final gteStart = flight.departureTime.compareTo(start) >= 0;
      final lteEnd = flight.arrivalTime.compareTo(end) <= 0;
      return gteStart && lteEnd;
    });
  }
}
