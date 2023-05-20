import 'flight_map_info.dart';

/// The types of maps we can display.
enum FlightMap {
  /// Mercator map projection of the world.
  worldMercatorProjection,

  /// Robinson map projection of the world.
  worldRobinsonProjection,
}

extension FlightMapX on FlightMap {
  /// Get info about our map (assets, aspect ratio...)
  FlightMapInfo get info {
    switch (this) {
      case FlightMap.worldMercatorProjection:
        return WorldMercatorInfo();
      case FlightMap.worldRobinsonProjection:
        return WorldRobinsonInfo();
    }
  }
}
