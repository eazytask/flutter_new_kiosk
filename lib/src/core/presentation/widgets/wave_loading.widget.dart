
import 'package:kiosk/src/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math show sin, pi;

enum WaveLoadingType { start, end, center }

class WaveLoading extends StatefulWidget {
  const WaveLoading({Key? key}) : super(key: key);

  @override
  _WaveLoadingState createState() => _WaveLoadingState();
}

class _WaveLoadingState extends State<WaveLoading>
    with SingleTickerProviderStateMixin {
  final int itemCount = 5;
  final double size = 40.0;
  late AnimationController? controller;

  @override
  void initState() {
    super.initState();

    controller = (AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200)))
      ..repeat();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<double> _bars = _startAnimationDelay(itemCount);
    return Center(
      child: SizedBox.fromSize(
        size: Size(size * 1.25, size),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_bars.length, (i) {
            return ScaleYWidget(
              scaleY: DelayTween(begin: .4, end: 1.0, delay: _bars[i])
                  .animate(controller!),
              child: SizedBox.fromSize(
                  size: Size(size / itemCount, size), child: _itemBuilder(i)),
            );
          }),
        ),
      ),
    );
  }

  // List<double> getAnimationDelay(int itemCount) {
  //   switch (widget.type) {
  //     case SpinKitWaveType.start:
  //       return _startAnimationDelay(itemCount);
  //     case SpinKitWaveType.end:
  //       return _endAnimationDelay(itemCount);
  //     case SpinKitWaveType.center:
  //     default:
  //       return _centerAnimationDelay(itemCount);
  //   }
  // }

  List<double> _startAnimationDelay(int count) {
    return <double>[
      ...List<double>.generate(
          count ~/ 2, (index) => -1.0 - (index * 0.1) - 0.1).reversed,
      if (count.isOdd) -1.0,
      ...List<double>.generate(
        count ~/ 2,
        (index) => -1.0 + (index * 0.1) + (count.isOdd ? 0.1 : 0.0),
      ),
    ];
  }

  List<double> _endAnimationDelay(int count) {
    return <double>[
      ...List<double>.generate(
          count ~/ 2, (index) => -1.0 + (index * 0.1) + 0.1).reversed,
      if (count.isOdd) -1.0,
      ...List<double>.generate(
        count ~/ 2,
        (index) => -1.0 - (index * 0.1) - (count.isOdd ? 0.1 : 0.0),
      ),
    ];
  }

  List<double> _centerAnimationDelay(int count) {
    return <double>[
      ...List<double>.generate(
          count ~/ 2, (index) => -1.0 + (index * 0.2) + 0.2).reversed,
      if (count.isOdd) -1.0,
      ...List<double>.generate(
          count ~/ 2, (index) => -1.0 + (index * 0.2) + 0.2),
    ];
  }

  Widget _itemBuilder(int index) => DecoratedBox(
          decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.kNormalGreen
            : AppColors.primaryColor,
      ));
}

class ScaleYWidget extends AnimatedWidget {
  const ScaleYWidget({
    Key? key,
    required Animation<double> scaleY,
    required this.child,
    this.alignment = Alignment.center,
  }) : super(key: key, listenable: scaleY);

  final Widget child;
  final Alignment alignment;

  Animation<double> get scale => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return Transform(
        transform: Matrix4.identity()..scale(1.0, scale.value, 1.0),
        alignment: alignment,
        child: child);
  }
}

class DelayTween extends Tween<double> {
  DelayTween({double? begin, double? end, required this.delay})
      : super(begin: begin, end: end);

  final double delay;

  @override
  double lerp(double t) =>
      super.lerp((math.sin((t - delay) * 2 * math.pi) + 1) / 2);

  @override
  double evaluate(Animation<double> animation) => lerp(animation.value);
}
