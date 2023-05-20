<p align="center">
  <a href="https://flutter.dev">
    <img src="https://img.shields.io/badge/Platform-Flutter-02569B?logo=flutter"
      alt="Platform" />
  </a>
  <a href="https://pub.dartlang.org/packages/multi_border">
    <img src="https://img.shields.io/pub/v/animated_flight_paths" alt="Animated Flight Paths Pub Package" />
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/github/license/benjamin-otto/animated_flight_paths" alt="MIT License"/>
  </a>
</p>


<p>  
    <img src="https://github.com/benjamin-otto/animated_flight_paths/blob/main/screenshots/animated_flight_paths.png?raw=true" alt="Animated Flight Paths" width="100%"/>
</p>

<p align="center">
A widget for adding animated flight paths to a map.
</p>

## Features

- Includes both Mercator and Robinson world map projections.
  - Or set any custom map or other background you choose.
- Many options for customizing the flight paths including colors and animation curves.
- Easily determine a point on the map using the `debugShowOffsetOnTap` and tapping or clicking.

## Quick Start

```dart
import 'package:animated_flight_paths/animated_flight_paths.dart';

class AnimatedFlightPathsExample extends StatefulWidget {
  const AnimatedFlightPathsExample({super.key});

  @override
  State<AnimatedFlightPathsExample> createState() =>
      _AnimatedFlightPathsExampleState();
}

class _AnimatedFlightPathsExampleState extends State<AnimatedFlightPathsExample>
    with SingleTickerProviderStateMixin {
  
  // Controls the flight path animations
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedFlightPaths(
      controller: controller,
      flightSchedule: FlightSchedule(
        // All flights must depart on or after [start] of schedule.
        start: DateTime.parse('2023-01-01 00:00:00'), 
        // All flights must arrive on or before [end] of schedule.
        end: DateTime.parse('2023-01-02 23:59:00'),
        flights: flights,
      )
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
```

[Create flight endpoints:](#determining-flight-endpoint-offsets)
```dart
abstract class Cities {
  static final newYork = FlightEndpoint(
    offset: const Offset(28, 51),
    label: const Text('New York'),
  );

  static final bangkok = FlightEndpoint(
    offset: const Offset(75, 65),
    label: const Text('Bangkok'),
  );
}
```

Create the flights to be animated:
```dart
final flights = <Flight>[
  Flight(
    from: Cities.newYork,
    to: Cities.bangkok,
    departureTime: DateTime.parse('2023-01-01 00:00:00'),
    arrivalTime: DateTime.parse('2023-01-01 19:30:00'),
  ),
  Flight(
    from: Cities.bangkok,
    to: Cities.newYork,
    departureTime: DateTime.parse('2023-01-02 00:00:00'),
    arrivalTime: DateTime.parse('2023-01-02 19:30:00'),
  ),
];
```

<p>  
    <img src="https://github.com/benjamin-otto/animated_flight_paths/blob/main/screenshots/screenshots/animated_flight_paths.gif?raw=true" alt="Animated Flight Paths" width="100%"/>
</p>

## Determining Flight Endpoint Offsets

<p>  
    <img src="https://github.com/benjamin-otto/animated_flight_paths/blob/main/screenshots/screenshots/map_coordinates.png?raw=true" alt="Map Coordinates" width="100%"/>
</p>

Easily determine coordinates with `debugShowOffsetOnTap`.

```dart
AnimatedFlightPaths(
  controller: controller,
  debugShowOffsetOnTap: true, // Set to true
  flightSchedule: FlightSchedule(
      start: DateTime.parse('2023-01-01 00:00:00'),
      end: DateTime.parse('2023-01-01 23:59:00'),
      flights: <Flight>[],
  ),
);
```

With `debugShowOffsetOnTap: true`  run the app and tap/click anywhere to display a 📍  and a tooltip with the coordinates of that position.

Fine-tune the 📍 position with the arrow keys [↑ ↓ → ←].

In the screenshot above the tooltip is showing **(21.99, 52.79)** which are the coordinates of **Kansas City**.

With those coordinates we can then create a new `FlightEndpoint`:

```dart
abstract class Cities {
  static final kansasCity = FlightEndpoint(
    offset: const Offset(21.99, 52.79),
    label: const Text('Kansas City'),
  );
}
```

Now use this endpoint in any of your flights.

✈️ Bon Voyage!!
