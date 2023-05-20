import 'package:flutter/material.dart';

import '../../../animated_flight_paths.dart';

class AnimatedLabel extends StatelessWidget {
  const AnimatedLabel({
    super.key,
    required this.endpoint,
    required this.options,
    required this.controller,
    required this.drawAnimations,
    required this.clearAnimations,
  });

  final FlightEndpoint endpoint;
  final FlightPathOptions options;
  final AnimationController controller;
  final Set<Animation<double>> drawAnimations;
  final Set<Animation<double>> clearAnimations;

  @override
  Widget build(BuildContext context) {
    return LayoutId(
      id: endpoint,
      child: AnimatedBuilder(
        animation: controller,
        child: endpoint.label,
        builder: (_, child) => Opacity(
          opacity: _opacity,
          child: child,
        ),
      ),
    );
  }

  double get _opacity => options.endpointLabelAlwaysVisible
      ? 1
      : (_drawValue - _clearValue).clamp(0, 1);

  double get _drawValue => _totalAnimationValue(drawAnimations);

  double get _clearValue => _totalAnimationValue(clearAnimations);

  double _totalAnimationValue(Set<Animation<double>> animations) =>
      animations.fold(0.0, (total, anim) => total + anim.value);
}
