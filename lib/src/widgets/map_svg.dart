import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../flight_map/flight_map.dart';

/// A widget to display an SVG map.
class MapSvg extends StatelessWidget {
  const MapSvg({
    super.key,
    this.map = FlightMap.worldMercatorProjection,
    this.fillColor = Colors.transparent,
    this.outlineColor = Colors.black,
  });

  /// Specifies which map svg to display.
  final FlightMap map;

  /// The countries fill color.
  final Color fillColor;

  // The countries outline color.
  final Color outlineColor;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: map.info.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _SvgMap(svgPath: map.info.fill, color: fillColor),
          _SvgMap(svgPath: map.info.outline, color: outlineColor),
        ],
      ),
    );
  }
}

class _SvgMap extends StatelessWidget {
  const _SvgMap({required this.svgPath, required this.color});

  final String svgPath;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      svgPath,
      package: 'animated_flight_paths',
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
