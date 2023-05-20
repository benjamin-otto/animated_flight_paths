abstract class FlightMapInfo {
  double get aspectRatio;
  String get assetsDir;
  String get fill;
  String get outline;
}

class WorldMercatorInfo implements FlightMapInfo {
  @override
  double get aspectRatio => 1969 / 1243;

  @override
  String get assetsDir => 'assets/mercator';

  @override
  String get fill => '$assetsDir/world_fill.svg';

  @override
  String get outline => '$assetsDir/world_outline.svg';
}

class WorldRobinsonInfo implements FlightMapInfo {
  @override
  double get aspectRatio => 2000 / 857;

  @override
  String get assetsDir => 'assets/robinson';

  @override
  String get fill => '$assetsDir/world_fill.svg';

  @override
  String get outline => '$assetsDir/world_outline.svg';
}
