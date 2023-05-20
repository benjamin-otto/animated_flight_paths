import 'dart:ui';

import 'flight.dart';

enum EndpointType { from, to }

enum LabelPosition {
  aboveEndpoint,
  belowEndpoint,
  leftOfEndpoint,
  rightOfEndpoint,
}

List<LabelPosition> calcPreferredLabelPositions(
  EndpointType endpointType,
  Flight flight,
) {
  final preferredPositions = <LabelPosition>[];
  final from = flight.from.offset;
  final to = flight.to.offset;
  final slope = (to.dy - from.dy) / (to.dx - from.dx);

  late Offset first;
  late Offset second;
  switch (endpointType) {
    case EndpointType.from:
      first = from;
      second = to;
      break;
    case EndpointType.to:
      first = to;
      second = from;
      break;
  }

  // Exactly vertical flight
  if (slope.isNaN) {
    preferredPositions.add(
      first.dy < second.dy
          ? LabelPosition.aboveEndpoint
          : LabelPosition.belowEndpoint,
    );
  }
  // Exactly horizontal flight
  else if (slope == 0) {
    preferredPositions.add(LabelPosition.belowEndpoint);
  }
  // Flight slightly angled from bottom-left to top-right
  else if (-1 <= slope && slope < 0) {
    preferredPositions.addAll(
      first.dy < second.dy
          ? [LabelPosition.belowEndpoint, LabelPosition.rightOfEndpoint]
          : [LabelPosition.belowEndpoint, LabelPosition.leftOfEndpoint],
    );
  }
  // Flight steeply angled from bottom-left to top-right
  else if (slope < -1) {
    preferredPositions.addAll(
      first.dy < second.dy
          ? [LabelPosition.aboveEndpoint, LabelPosition.rightOfEndpoint]
          : [LabelPosition.belowEndpoint, LabelPosition.leftOfEndpoint],
    );
  }
  // Flight slightly angled from top-left to bottom-right
  else if (0 < slope && slope <= 1) {
    preferredPositions.addAll(
      first.dy < second.dy
          ? [LabelPosition.belowEndpoint, LabelPosition.leftOfEndpoint]
          : [LabelPosition.belowEndpoint, LabelPosition.rightOfEndpoint],
    );
  }
  // Flight steeply angled from top-left to bottom-right
  else if (slope > 1) {
    preferredPositions.addAll(
      first.dy < second.dy
          ? [LabelPosition.aboveEndpoint, LabelPosition.leftOfEndpoint]
          : [LabelPosition.belowEndpoint, LabelPosition.rightOfEndpoint],
    );
  }

  return preferredPositions;
}
