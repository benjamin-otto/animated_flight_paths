import 'flight_animations.dart';
import 'flight_label_position.dart';
import 'flight.dart';

class FlightComposition {
  FlightComposition(
    this.flight,
    this.animations,
  )   : fromPrefLabelPositions =
            calcPreferredLabelPositions(EndpointType.from, flight),
        toPrefLabelPositions =
            calcPreferredLabelPositions(EndpointType.to, flight);

  final Flight flight;
  final FlightAnimations animations;
  final List<LabelPosition> fromPrefLabelPositions;
  final List<LabelPosition> toPrefLabelPositions;
}
