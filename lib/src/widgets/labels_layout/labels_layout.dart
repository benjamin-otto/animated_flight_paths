import 'package:flutter/material.dart';

import '../../extensions.dart';
import '../../flight/flight.dart';
import '../../flight/flight_composition.dart';
import '../../flight/flight_endpoint.dart';
import '../../flight/flight_label_position.dart';
import '../../flight/flight_path_options.dart';
import 'animated_label.dart';

class LabelsLayout extends StatelessWidget {
  const LabelsLayout({
    super.key,
    required this.flightComps,
    required this.options,
    required this.controller,
  });

  final List<FlightComposition> flightComps;
  final FlightPathOptions options;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _LabelsLayoutDelegate(
        endpointLabelPositions: _endpointLabelPositions,
        options: options,
        controller: controller,
      ),
      children: [..._animatedLabels],
    );
  }

  Map<FlightEndpoint, LabelPosition> get _endpointLabelPositions {
    final preferredPositions = <FlightEndpoint, List<LabelPosition>>{};
    for (final flightComp in flightComps) {
      final Flight(:from, :to) = flightComp.flight;
      preferredPositions[from] ??= <LabelPosition>[];
      preferredPositions[to] ??= <LabelPosition>[];
      from.labelPosition != null
          ? preferredPositions[from]!.add(from.labelPosition!)
          : preferredPositions[from]!.addAll(flightComp.fromPrefLabelPositions);
      to.labelPosition != null
          ? preferredPositions[to]!.add(to.labelPosition!)
          : preferredPositions[to]!.addAll(flightComp.toPrefLabelPositions);
    }

    final endpointLabelPositions = <FlightEndpoint, LabelPosition>{};
    for (final entry in preferredPositions.entries) {
      final MapEntry(key: endpoint, value: labelPositions) = entry;
      final positionCounts = labelPositions.fold(
        <LabelPosition, int>{},
        (positionCounts, labelPosition) {
          positionCounts[labelPosition] ??= 0;
          positionCounts[labelPosition] = positionCounts[labelPosition]! + 1;
          return positionCounts;
        },
      );
      final sortedPositionCounts = positionCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      endpointLabelPositions[endpoint] = sortedPositionCounts[0].key;
    }

    return endpointLabelPositions;
  }

  List<AnimatedLabel> get _animatedLabels {
    final animatedLabels = <AnimatedLabel>[];
    final allEndpoints = <FlightEndpoint>{};
    final drawAnimations = <FlightEndpoint, Set<Animation<double>>>{};
    final clearAnimations = <FlightEndpoint, Set<Animation<double>>>{};

    for (final flightComp in flightComps) {
      final FlightComposition(:flight, :animations) = flightComp;
      final Flight(:from, :to) = flight;
      (drawAnimations[from] ??= {}).add(animations.fromDrawAnim);
      (drawAnimations[to] ??= {}).add(animations.toDrawAnim);
      (clearAnimations[from] ??= {}).add(animations.fromClearAnim);
      (clearAnimations[to] ??= {}).add(animations.toClearAnim);
      allEndpoints.addAll([from, to]);
    }

    for (final endpoint in allEndpoints) {
      animatedLabels.add(AnimatedLabel(
        endpoint: endpoint,
        options: options,
        controller: controller,
        drawAnimations: drawAnimations[endpoint] ?? {},
        clearAnimations: clearAnimations[endpoint] ?? {},
      ));
    }

    return animatedLabels;
  }
}

class _LabelsLayoutDelegate extends MultiChildLayoutDelegate {
  _LabelsLayoutDelegate({
    required this.endpointLabelPositions,
    required this.options,
    required this.controller,
  }) : super(relayout: controller);

  final Map<FlightEndpoint, LabelPosition> endpointLabelPositions;
  final FlightPathOptions options;
  final AnimationController controller;

  @override
  void performLayout(Size size) {
    for (final MapEntry(key: endpoint, value: labelPosition)
        in endpointLabelPositions.entries) {
      _layoutLabel(endpoint, labelPosition, size);
    }
  }

  void _layoutLabel(
    FlightEndpoint endpoint,
    LabelPosition labelPosition,
    Size size,
  ) {
    if (endpoint.label == null || !hasChild(endpoint)) return;

    final endpointOffset = endpoint.offset.multiplyBySize(size);
    final labelSize = layoutChild(endpoint, BoxConstraints.loose(size));
    final centeredToEndpoint = Offset(
      endpointOffset.dx - (labelSize.width / 2),
      endpointOffset.dy - (labelSize.height / 2),
    );
    final shiftMag = options.endpointRadius + options.endpointToLabelSpacing;
    final halfWidth = labelSize.width / 2;
    final halfHeight = labelSize.height / 2;
    double xShift = 0;
    double yShift = 0;

    switch (labelPosition) {
      case LabelPosition.aboveEndpoint:
        yShift = -(shiftMag + halfHeight);
        break;
      case LabelPosition.belowEndpoint:
        yShift = shiftMag + halfHeight;
        break;
      case LabelPosition.leftOfEndpoint:
        xShift = -(shiftMag + halfWidth);
        break;
      case LabelPosition.rightOfEndpoint:
        xShift = shiftMag + halfWidth;
        break;
    }

    positionChild(
      endpoint,
      Offset(
        centeredToEndpoint.dx + xShift,
        centeredToEndpoint.dy + yShift,
      ),
    );
  }

  @override
  bool shouldRelayout(_LabelsLayoutDelegate oldDelegate) =>
      endpointLabelPositions != oldDelegate.endpointLabelPositions ||
      options != oldDelegate.options ||
      controller != oldDelegate.controller;
}
