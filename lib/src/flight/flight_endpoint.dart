import 'package:flutter/material.dart';

import '../extensions.dart';
import 'flight_label_position.dart';

/// Represents a "from" or "to" location for our flight path.
class FlightEndpoint {
  FlightEndpoint({
    required Offset offset,
    this.label,
    this.labelPosition,
  })  : assert(offset.dx.inInclusiveRange(0, 100)),
        assert(offset.dy.inInclusiveRange(0, 100)),
        offset = offset / 100;

  /// The position of the map location.
  ///
  /// Top-left of the map is (0,0)
  ///
  /// Bottom-right of the map is (map width, map height).
  ///
  /// TIP: Set [AnimatedFlightPaths.debugShowOffsetOnTap] = true.
  ///
  /// Then simply tap/click on the map to get the location's [Offset].
  final Offset offset;

  /// The label to be displayed next to the circular endpoint.
  final Widget? label;

  /// Set the label position above, below, left, or right of endpoint.
  ///
  /// If let unset then the position will be calculated automatically.
  ///
  /// Useful when [FlightOptions.endpointLabelAlwaysVisible] is true.
  /// In this case if many labels are always visible they might overlap.
  /// Use this option to place them as you prefer.
  final LabelPosition? labelPosition;

  /// Use value equality instead of reference equality.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FlightEndpoint &&
        other.offset == offset &&
        other.label == label;
  }

  /// Use value equality instead of reference equality.
  @override
  int get hashCode => Object.hash(offset, label);
}
